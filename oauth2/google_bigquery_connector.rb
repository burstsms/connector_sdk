{
  title: "Google BigQuery",

  connection: {
    fields: [
      {
        name: "client_id",
        hint: "Find it " \
          "<a href='https://console.cloud.google.com/apis/credentials'>" \
          "here</a>",
        optional: false,
      },
      {
        name: "client_secret",
        hint: "Find it " \
          "<a href='https://console.cloud.google.com/apis/credentials'>" \
          "here</a>",
        optional: false,
        control_type: "password",
      }
    ],

    authorization: {
      type: "oauth2",

      authorization_url: lambda do |connection|
        scopes = [
          "https://www.googleapis.com/auth/bigquery",
          "https://www.googleapis.com/auth/bigquery.insertdata",
          "https://www.googleapis.com/auth/cloud-platform",
          "https://www.googleapis.com/auth/cloud-platform.read-only",
          "https://www.googleapis.com/auth/devstorage.full_control",
          "https://www.googleapis.com/auth/devstorage.read_only",
          "https://www.googleapis.com/auth/devstorage.read_write",
        ].join(" ")

        "https://accounts.google.com/o/oauth2/auth?client_id=" \
          "#{connection['client_id']}&response_type=code&scope=#{scopes}" \
          "&access_type=offline&include_granted_scopes=true&prompt=consent"
      end,

      acquire: lambda do |connection, auth_code, redirect_uri|
        response = post("https://accounts.google.com/o/oauth2/token").
                    payload(client_id: connection["client_id"],
                            client_secret: connection["client_secret"],
                            grant_type: "authorization_code",
                            code: auth_code,
                            redirect_uri: redirect_uri).
                    request_format_www_form_urlencoded

        [response, nil, nil]
      end,

      refresh: lambda do |connection, refresh_token|
        post("https://accounts.google.com/o/oauth2/token").
          payload(client_id: connection["client_id"],
                  client_secret: connection["client_secret"],
                  grant_type: "refresh_token",
                  refresh_token: refresh_token).
          request_format_www_form_urlencoded
      end,

      refresh_on: [401],

      detect_on: [/"errors"\:\s*\[/],

      apply: lambda do |_connection, access_token|
        headers(Authorization: "Bearer #{access_token}")
      end,
    },
  },

  test: lambda do |_connection|
    get("https://www.googleapis.com/bigquery/v2/projects").
      params(maxResults: 1)
  end,

  object_definitions: {
    table_schema: {
      fields: lambda do |_connection, config_fields|
        project_id = config_fields["project"]
        dataset_id = config_fields["dataset"]
        table_id = config_fields["table"]
        table_fields = if project_id && dataset_id && table_id
                         get("https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets/#{dataset_id}/tables/#{table_id}").
                           dig("schema", "fields")
                       else
                         []
                       end
        type_map = {
          "BYTES" => "string",
          "INTEGER" => "integer", "INT64" => "integer",
          "FLOAT" => "number", "FLOAT64" => "number",
          "BOOLEAN" => "boolean", "BOOL" => "boolean",
          "TIMESTAMP" => "timestamp",
          "DATE" => "date",
          "TIME" => "string",
          "DATETIME" => "string",
          "RECORD" => "object", "STRUCT" => "object",
        }
        hint_map = {
          "BOOLEAN" => " | Boolean values are represented by the keywords true and false (case insensitive). Example: true",
          "TIME" => " | Represents a time, independent of a specific date. Example: 11:16:00.000000",
          "DATETIME" => " | Represents a year, month, day, hour, minute, second, and subsecond. Example: 2017-09-13T11:16:00.000000",
        }

        build_schema_field = lambda do |field|
          field_name = field["name"].downcase
          field_label = field["name"].humanize
          field_hint = if field["description"] && hint_map[field["type"]]
                         field["description"] + hint_map[field["type"]]
                       else
                         field["description"] || hint_map[field["type"]]
                       end
          field_optional = (field["mode"] != "REQUIRED")
          field_type = type_map[field["type"]]
          if %w[RECORD STRUCT].include? field["type"]
            {
              name: field_name,
              label: field_label,
              hint: field_hint,
              optional: field_optional,
              type: field_type,
              properties: field["fields"].map do |inner_field|
                build_schema_field[inner_field]
              end
            }
          else
            {
              name: field_name,
              label: field_label,
              hint: field_hint,
              optional: field_optional,
              type: field_type,
            }
          end
        end

        table_schema_fields = [
          {
            name: "insertId",
            label: "Insert id",
            hint: "A unique ID for each row. Google BigQuery uses this" \
             "property to detect duplicate insertion requests on a"     \
             " best-effort basis"
          }
        ].concat(table_fields.
              map do |table_field|
                build_schema_field[table_field]
              end)

        [
          name: "rows",
          optional: false,
          type: "array",
          of: "object",
          properties: table_schema_fields
        ]
      end
    }
  },

  actions: {
    add_rows: {
      description: "Add <span class='provider'>rows</span> to dataset" \
        " in <span class='provider'>Google BigQuery</span>",
      subtitle: "Add data rows",
      help: "Streams data into a table of Google BigQuery.",

      config_fields: [
        {
          name: "project",
          hint: "Select the appropriate Project to import data",
          optional: false,
          control_type: "select",
          pick_list: "projects",
        },
        {
          name: "dataset",
          control_type: "select",
          pick_list: "datasets",
          pick_list_params: { project_id: "project" },
          optional: false,
          hint: "Select a dataset to view list of tables",
        },
        {
          name: "table",
          control_type: "select",
          pick_list: "tables",
          pick_list_params: { project_id: "project", dataset_id: "dataset" },
          optional: false,
          hint: "Select a table to stream data",
        },
      ],

      input_fields: lambda do |object_definitions|
        object_definitions["table_schema"]
      end,

      execute: lambda do |_connection, input|
        post("https://www.googleapis.com/bigquery/v2/projects/" \
          "#{input['project']}/datasets/#{input['dataset']}/"   \
          "tables/#{input['table']}/insertAll").
          params(fields: "kind,insertErrors").
          payload(rows: (input["rows"] || []).map do |row|
                          {
                            insertId: row.delete("insertId") || "",
                            json: row
                          }
                        end)
      end,

      output_fields: lambda do |_object_definitions|
        [{ name: "kind" }]
      end,

      sample_output: lambda do
        { kind: "bigquery#tableDataInsertAllResponse" }
      end
    }
  },

  pick_lists: {
    projects: lambda do |_connection|
      get("https://www.googleapis.com/bigquery/v2/projects").
        dig("projects").
        map do |project|
          [project["friendlyName"], project["id"]]
        end
    end,

    datasets: lambda do |_connection, project_id:|
      get("https://www.googleapis.com/bigquery/v2/projects/" \
        "#{project_id}/datasets").
        dig("datasets").
        map do |dataset|
          [
            dataset["datasetReference"]["datasetId"],
            dataset["datasetReference"]["datasetId"]
          ]
        end
    end,

    tables: lambda do |_connection, project_id:, dataset_id:|
      get("https://www.googleapis.com/bigquery/v2/projects/" \
        "#{project_id}/datasets/#{dataset_id}/tables").
        dig("tables").map do |table|
          [
            table["tableReference"]["tableId"],
            table["tableReference"]["tableId"]
          ]
        end
    end
  }
}
