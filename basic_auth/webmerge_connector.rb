{
  title: 'WebMerge',

  # HTTP basic auth example.
  connection: {
    fields: [
      {
        name: 'api_key',
        optional: false,
        hint: 'Your WebMerge API Key'
      },
      {
        name: 'api_secret',
        control_type: 'password',
        label: 'Your WebMerge API Secret'
      }
    ],

    authorization: {
      type: 'basic_auth',

      # Basic auth credentials are just the username and password; framework handles adding
      # them to the HTTP requests.
      credentials: ->(connection) {
        user(connection['api_key'])
        password(connection['api_secret'])
      }
    }
  },

  object_definitions: {
  
    document: {

      fields: lambda do |connection, config_fields|
        # here, you can use the input from the input from the user (in this case, config_field)
        if config_fields.present?
          d = config_fields["document_id"].split('|');
          fields = get("https://www.webmerge.me/api/documents/#{d.first}/fields")
          fields.map do |field|
            {
              name: field["name"],
              label: field["name"]
            }
          end
        else
          []
        end
      end
    },
    
    route: {

      fields: lambda do |connection, config_fields|
        # here, you can use the input from the input from the user (in this case, config_field)
        if config_fields.present?
          r = config_fields["route_id"].split('|');
          fields = get("https://www.webmerge.me/api/routes/#{r.first}/fields")
          fields.map do |field|
            {
              name: field["name"],
              label: field["name"]
            }
          end
        else
          []
        end
      end
    }
  },
  
  test: ->(connection) {
    get("https://www.webmerge.me/api/account")
  },
  
  actions: {  
    merge_document: {
      config_fields: [
        # this field shows up first in recipe as a picklist of documents to use
        {
          name: "document_id",
          label: "Document",
          control_type: :select,
          pick_list: "documents",
          optional: false
        }
      ],

      input_fields: ->(object_definition) {
        object_definition["document"]
      },

      execute: lambda do |_connection, input|
        d = input["document_id"].split("|")
        post(d.last.to_s, input)
      end,

      output_fields: lambda do |_object_definition|
        [
          {
            name: "success"
          }
        ]
      end
    },
    
    merge_route: {
      config_fields: [
        # this field shows up first in recipe as a picklist of routes to use
        {
          name: "route_id",
          label: "Route",
          control_type: :select,
          pick_list: "routes",
          optional: false
        }
      ],

      input_fields: ->(object_definition) {
        object_definition["route"]
      },

      execute: lambda do |_connection, input|
        r = input["route_id"].split("|")
        post(r.last.to_s, input)
      end,

      output_fields: lambda do |_object_definition|
        [
          {
            name: "success"
          }
        ]
      end
    } 
  },
  
  pick_lists: {
    documents: lambda do |_connection|
      get("https://www.webmerge.me/api/documents").map do |document|
        [document["name"], document["id"] + "|" + document["url"]]
      end
    end,    
    routes: lambda do |_connection|
      get("https://www.webmerge.me/api/routes").map do |route|
        [route["name"], route["id"] + "|" + route["url"]]
      end
    end
  }
}
