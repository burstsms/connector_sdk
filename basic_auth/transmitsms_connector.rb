{
  title: 'Transmit SMS',
  connection: {
    fields: [
      {
        name: 'api_key',
        label: 'API Key',
        hint: "Found in the SETTINGS section of your transmitsms.com account.",
        optional: false
      },
      {
        name: 'secret',
        control_type: 'password',
        label: 'API Secret',
        hint: "Found in the SETTINGS section of your transmitsms.com account. If blank enter a secret and click UPDATE PROFILE at the bottom of the page",
        optional: false
      }
    ],
    authorization: {
      type: 'basic_auth',
    credentials: ->(connection) {
      user(connection['api_key'])
      password(connection['secret'])
    }
    }
  },
  test: ->(connection) {
    get("https://api.transmitsms.com/get-balance.json")
  },
  object_definitions: {
    # please refer to https://support.burstsms.com/hc/en-us/articles/202500828-send-sms
    format_number_request: {
      fields: ->() {
        [
          {
            name: 'to',
            type: 'phone',
            control_type: "phone",
            label: "Recipient Mobile Number",
            optional: false
            }, 
          {
            name: 'countrycode',
            control_type: :select,
            label: "Format Number",
            hint: 'Automatically formats numbers given to international format required for reliable SMS delivery. eg. In Australia 0422222222 will become 6142222222 when country code is set to AU.',
            optional: false,
            pick_list: [
              ["Australia", "AU"],
              ["New Zealand", "NZ"],
              ["United Kingdom", "GB"],
              ["United States", "US"],
              ["Singapore", "SG"]
            ],
            toggle_hint: "Select Country",
            toggle_field: {
              name: 'countrycode',
              label: "Format Number",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Variable",
              hint: 'Automatically formats numbers given to international format required for reliable SMS delivery. eg. In Australia 0422222222 will become 6142222222 when country code is set to AU.',
            }
          }
        ]
      }
    },
    # please see response section of https://support.burstsms.com/hc/en-us/articles/203098949-format-number
    format_number_response: {
      fields: ->() {
        [
          {
            name: 'error',
            type: 'object',
            properties: [
              { name: 'code', type: 'string' },
              { name: 'description', type: 'string'}
            ]
          },
          {
            name: 'number',
            type: 'object',
            properties: [
              { name: 'international', type: 'string' },
              { name: 'countrycode', type: 'string' },
              { name: 'isValid', type: 'boolean' },
              { name: 'national_leading_zeroes', type: 'string' },
              { name: 'nationalnumber', type: 'string' },
              { name: 'rawinput', type: 'string' },
              { name: 'type', type: 'integer' }
            ]
          }
        ]
      }
    },
    # please refer to https://support.burstsms.com/hc/en-us/articles/202500828-send-sms
    send_sms_request: {
      fields: ->() {
        [
          {
            name: 'message',
            label: "Message Body",
            type: 'string',
            control_type: 'text-area',
            optional: false
            },
          {
            name: 'to',
            type: 'phone',
            control_type: "phone",
            label: "Recipient Mobile Number",
            optional: false
            }, 
          {
            name: 'countrycode',
            control_type: :select,
            label: "Format Number",
            hint: 'Automatically formats numbers given to international format required for reliable SMS delivery. eg. In Australia 0422222222 will become 6142222222 when country code is set to AU.',
            optional: true,
            pick_list: [
              ["Australia", "AU"],
              ["New Zealand", "NZ"],
              ["United Kingdom", "GB"],
              ["United States", "US"],
              ["Singapore", "SG"]
            ],
            toggle_hint: "Select Country",
            toggle_field: {
              name: 'countrycode',
              label: "Format Number",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Variable",
              hint: 'Automatically formats numbers given to international format required for reliable SMS delivery. eg. In Australia 0422222222 will become 6142222222 when country code is set to AU.',
            }
          },
          {
            name: 'virtual_number',
            control_type: "select", 
            pick_list: "numbers",
            label: "Sender ID",
            hint: 'Can be left blank to use default shared number, static mobile number as sender or alphanumeric if <a href="https://support.burstsms.com/hc/en-us/articles/213656066-Global-SMS-Delivery-List">supported</a>.',
            optional: true,
            toggle_hint: "Select Virtual Number",
            toggle_field: {
              name: 'sender_id',
              label: "Sender ID",
              type: :string,
              control_type: "text",
              optional: true,
              toggle_hint: "Use Custom Sender ID or Variable",
              hint: 'Can be left blank to use default shared number, static mobile number as sender or alphanumeric if <a href="https://support.burstsms.com/hc/en-us/articles/213656066-Global-SMS-Delivery-List">supported</a>.'
            }
          }
        ]
      }
    },
    # please refer to response section of https://support.burstsms.com/hc/en-us/articles/202500828-send-sms
    send_sms_response: {
      fields: ->() {
        [
          {
            name: 'results',
            type: 'object',
            properties: [
              { name: 'message_id', type: 'string' },
              { name: 'send_at', type: 'string' },
              { name: 'recipients', type: 'string' },
              { name: 'mobile', type: 'string' },
              { name: 'cost', type: 'string' },
              {
                name: 'error',
                type: 'object',
                properties: [
                  { name: 'code', type: 'string' },
                  { name: 'description', type: 'string' }
                ]
              },
              {
                name: 'delivery_stats',
                type: 'object',
                properties: [
                  { name: 'delivered',type: 'string' },
                  { name: 'pending',type: 'string' },
                  { name: 'bounced', type: 'string' },
                  { name: 'responses',type: 'string' },
                  { name: 'optouts', type: 'string' }
                ]
              }
            ]
          }
        ]
      }
    },
    # please refer to https://support.burstsms.com/hc/en-us/articles/202500828-send-sms
    send_sms_list_request: {
      fields: ->() {
        [
          { 
            name: "list_id", 
            control_type: "select", 
            pick_list: "contactList",
            label: "List that the contact is in.",
            optional: false
          },
          {
            name: 'message',
            label: "Message Body",
            type: 'string',
            control_type: 'text-area',
            optional: false
          },     
          {
            name: 'virtual_number',
            control_type: "select", 
            pick_list: "numbers",
            label: "Sender ID",
            hint: 'Can be left blank to use default shared number, static mobile number as sender or alphanumeric if <a href="https://support.burstsms.com/hc/en-us/articles/213656066-Global-SMS-Delivery-List">supported</a>.',
            optional: true,
            toggle_hint: "Select Virtual Number",
            toggle_field: {
              name: 'sender_id',
              label: "Sender ID",
              type: :string,
              control_type: "text",
              optional: true,
              toggle_hint: "Use Custom Sender ID or Variable",
              hint: 'Can be left blank to use default shared number, static mobile number as sender or alphanumeric if <a href="https://support.burstsms.com/hc/en-us/articles/213656066-Global-SMS-Delivery-List">supported</a>.'
            }
          }
        ]
      }
    },
    # please refer to https://support.burstsms.com/hc/en-us/articles/203116337-HTTP-Callbacks
    sms_notification: {
      fields: ->() {
        [
          {
            name: 'message_id',
            type: 'string',
            hint: 'message unique indetifier',
            optional: false
          },
          {
            name: 'mobile',
            type: 'string',
            hint: 'Senders mobile'
          },
          {
            name: 'longcode',
            type: 'string',
            hint: 'The number message was delivered to'
          },
          {
            name: 'datetime_entry',
            type: 'string',
            hint: 'Date/time of delivery. UTC.'
          },
          {
            name: 'response',
            hint: 'Message text'
          },
          {
            name: 'is_optout',
            hint: 'Opt-out flag. yes or no'
          }
        ]
      }
    },
    # please refer to https://support.burstsms.com/hc/en-us/articles/203139007-add-to-list
    add_contact_to_list_request: {
      fields: ->(connection, config_fields) {
        if config_fields.blank?
        fields = []
        else 
          fields = get("https://api.transmitsms.com/get-list.json",{
            "list_id": config_fields["list_id"]
          })["fields"].map do |key, value|
            {
              name: key,
              type: 'string',
              label: value,
              hint: '',
              optional: true
            }
          end
        end

        fields << {
          name: 'first_name',
          type: 'string',
          label: "First Name",
          hint: '',
          optional: true
        }

        fields << {
          name: 'last_name',
          type: 'string',
          label: "Last Name",
          hint: '',
          optional: true
        }

        fields << {
          name: 'to',
          type: 'phone',
          control_type: "phone",
          label: "Recipient Mobile Number",
          optional: false
        }

        fields << {
          name: 'countrycode',
          control_type: :select,
          label: "Country Code",
          hint: 'Automatically formats numbers given to international format required for reliable SMS delivery. eg. In Australia 0422222222 will become 6142222222 when country code is set to AU.',
          optional: false,
          pick_list: [
            ["Australia", "AU"],
            ["New Zealand", "NZ"],
            ["United Kingdom", "GB"],
            ["United States", "US"],
            ["Singapore", "SG"]
          ],
          toggle_hint: "Select Country",
          toggle_field: {
            name: 'countrycode',
            label: "Format Number",
            type: :string,
            control_type: "text",
            optional: false,
            toggle_hint: "Use Variable",
            hint: 'Automatically formats numbers given to international format required for reliable SMS delivery. eg. In Australia 0422222222 will become 6142222222 when country code is set to AU.',
          }
        }
      }
    },
    # please refer to response section of https://support.burstsms.com/hc/en-us/articles/203139007-add-to-list
    add_contact_to_list_response: {
      fields: ->(connection, config_fields) {
        if config_fields.blank?
        fields = []
        else 
          fields = get("https://api.transmitsms.com/get-list.json",{
            "list_id": config_fields["list_id"]
          })["fields"].map do |key, value|
            { name: key, type: 'string' }
          end
        end

        fields << { name: 'first_name', type: :string }
        fields << { name: 'last_name', type: :string }
        fields << { name: 'msisdn', type: :string }
        fields << { name: 'list_id', type: :string }
      }
    },
    new_contact_notification: {
      fields: ->(connection, config_fields) {
        if config_fields.blank?
        fields = []
        else 
          fields = get("https://api.transmitsms.com/get-list.json",{
            "list_id": config_fields["list_id"]
          })["fields"].map do |key, value|
            { name: key, type: 'string' }
          end
        end
        fields << { name: 'type', type: :string }
        fields << { name: 'firstname', type: :string }
        fields << { name: 'lastname', type: :string }
        fields << { name: 'mobile', type: :string }
        fields << { name: 'list_id', type: :string }
        fields << { name: 'datetime_entry', type: :string }
      }
    },
    #please refer to https://support.burstsms.com/hc/en-us/articles/202064463-delete-from-list
    delete_contact_to_list_request: {
      fields: ->() {
        [
          { 
            name: "list_id", 
            control_type: "select", 
            pick_list: "contactList",
            label: "Choose the List you want to add/update the contact from",
            optional: false
          },
          {
            name: 'to',
            type: 'phone',
            control_type: "phone",
            label: "Recipient Mobile Number",
            optional: false
          },
          {
            name: 'countrycode',
            control_type: :select,
            label: "Country Code",
            hint: 'Automatically formats numbers given to international format required for reliable SMS delivery. eg. In Australia 0422222222 will become 6142222222 when country code is set to AU.',
            optional: false,
            pick_list: [
              ["Australia", "AU"],
              ["New Zealand", "NZ"],
              ["United Kingdom", "GB"],
              ["United States", "US"],
              ["Singapore", "SG"]
            ],
            toggle_hint: "Select Country",
            toggle_field: {
              name: 'countrycode',
              label: "Format Number",
              type: :string,
              control_type: "text",
              optional: false,
              toggle_hint: "Use Variable",
              hint: 'Automatically formats numbers given to international format required for reliable SMS delivery. eg. In Australia 0422222222 will become 6142222222 when country code is set to AU.',
            }
          }
        ]
      }
    },
    #please refer to response section of https://support.burstsms.com/hc/en-us/articles/202064463-delete-from-list
    delete_contact_to_list_response: {
      fields: ->() {
        [
          { 
            name: "list_ids", 
            type: :array,
            properties: []
          }
        ]
      }
    },
    #please refer to response section of https://support.burstsms.com/hc/en-us/articles/360000158136-get-contact
    get_contact_response:{
      fields: ->(connection, config_fields) {
        if config_fields.blank?
        fields = []
        else 
          fields = get("https://api.transmitsms.com/get-list.json",{
            "list_id": config_fields["list_id"]
          })["fields"].map do |key, value|
            { name: key, type: 'string' }
          end
        end

        fields << { name: 'first_name', type: 'string' }
        fields << { name: 'last_name', type: 'string' }
        fields << { name: 'msisdn', type: :string }
        fields << { name: 'list_id', type: :string }
        fields << { name: 'created_at', type: :string }
        fields << { name: 'status', type: :status }
        fields << { 
          name: 'error', 
          type: :object,
          properties: [
            { name: 'code',type: 'string' },
            { name: 'description',type: 'string' },
          ]
        }         
      }
    },
    #please refer to response section of https://support.burstsms.com/hc/en-us/articles/202064243-get-responses
    get_sms_response: {
      fields: ->() {
        [
          { name: 'id', type: 'string' },
          { name: 'message_id', type: 'string' },
          { name: 'received_at', type: 'string' },
          { name: 'first_name', type: 'string' },
          { name: 'last_name', type: 'string' },
          { name: 'msisdn', type: 'string' },
          { name: 'response', type: 'string' },
          { name: 'longcode', type: 'string' }
        ]
      }
    },

  },
  actions: {
    FormatNumber: {
      title: 'Format Number',
      description: "Format a single mobile number.",
      input_fields: ->(object_definitions) {
        object_definitions['format_number_request']
      },
      execute: ->(connection, input) {
        format_number_input = {
          "msisdn" => input["to"]
        }
        if(input["countrycode"].present?)
          format_number_input["countrycode"] = input["countrycode"].to_country_alpha2
        end
        get("https://api.transmitsms.com/format-number.json",format_number_input)
      },
      output_fields: ->(object_definitions) {
        object_definitions['format_number_response']
      }
    },
    SendSMS: {
      title: 'Send SMS',
      description: "Send a text message to a single mobile number.",
      input_fields: ->(object_definitions) {
        object_definitions['send_sms_request']
      },
      execute: ->(connection, input) {
        format_number_input = {
          "msisdn" => input["to"]
        }
        if(input["countrycode"].present?)
          format_number_input["countrycode"] = input["countrycode"].to_country_alpha2
        end
        number = get("https://api.transmitsms.com/format-number.json",format_number_input)
        if number["number"].include?("isValid")
          params = {
            "message" => input["message"],
            "to" => number["number"]["international"]
          }
          if(input["virtual_number"].present?)
            from = input["virtual_number"]
          end
          if(input["sender_id"].present?) 
            from = input["sender_id"]
          end
          if(from.present?)
            params["from"] = from
          end
          results = get("https://api.transmitsms.com/send-sms.json",params)
          results["mobile"] = number["number"]["international"]
          { results: results }
        end
      },
      output_fields: ->(object_definitions) {
        object_definitions['send_sms_response']
      }
    },
    SendSMSToList: {
      title: 'Send SMS To List',
      description: "Send a text message to a list of contact.",
      input_fields: ->(object_definitions) {
        object_definitions['send_sms_list_request']
      },
      execute: ->(connection, input) {
        params = {
          "message" => input["message"],
          "list_id" => input["list_id"]
        }
        if(input["virtual_number"].present?)
          from = input["virtual_number"]
        end
        if(input["sender_id"].present?) 
          from = input["sender_id"]
        end
        if(from.present?)
          params["from"] = from
        end
        results = get("https://api.transmitsms.com/send-sms.json",params)
        { results: results }
      },

      output_fields: ->(object_definitions) {
        object_definitions['send_sms_response']
        }
    },
    AddContact: {
      title: 'Add/Update Contact',
      description: "Adds or update a contact on a Burst SMS list.",
      config_fields: [
        { 
          name: "list_id", 
          control_type: "select", 
          pick_list: "contactList",
          label: "Choose the List you want to add/update the contact from",
          optional: false
        }
      ],
      input_fields: ->(object_definitions) {
        object_definitions['add_contact_to_list_request']
      },
      execute: ->(connection, input) {
        number = get("https://api.transmitsms.com/format-number.json").
        params( msisdn: input["to"], countrycode: input["countrycode"].to_country_alpha2)
        if number["number"].include?("isValid")
          input["msisdn"] = number["number"]["international"]
          put("https://frontapi.transmitsms.com/zapier/add-to-list.json",input)
        end
      },
      output_fields: ->(object_definitions) {
        object_definitions['add_contact_to_list_response']
      }
    },
    DeleteContact: {
      title: 'Delete Contact',
      description: "Delete a contact on a Burst SMS list.",
      input_fields: ->(object_definitions) {
        object_definitions['delete_contact_to_list_request']
      },
      execute: ->(connection, input) {

        number = get("https://api.transmitsms.com/format-number.json").
        params(msisdn: input["to"], countrycode: input["countrycode"].to_country_alpha2)

        if number["number"].include?("isValid")

        params = {
          "list_id" => input["list_id"],
          "msisdn" => number["number"]["international"]
        }

        put("https://frontapi.transmitsms.com/zapier/delete-from-list.json",params)

        end
      },
      output_fields: ->(object_definitions) {
        object_definitions['delete_contact_to_list_response']
      }
    },
    GetContact: {
      title: 'Get Contact',
      description: "Get contact information from a list.",
      config_fields:[
        { 
          name: "list_id", 
          control_type: "select", 
          pick_list: "contactList",
          label: "List that the contact is in.",
          optional: false
        }
      ],
      input_fields: ->() {
        [
          {
            name: 'msisdn',
            type: 'mobile',
            control_type: "phone",
            label: "Recipient Mobile Number",
            optional: false
          }
        ]
      },
      execute: ->(connection, input) {
        get("https://api.transmitsms.com/get-contact.json").
          params(msisdn: input["msisdn"], list_id: input["list_id"])
      },
      output_fields: lambda do |object_definitions|
        object_definitions['get_contact_response']
      end
    }
  },
  triggers: {
    new_message: {
      title: "Message received",
      description: "Message received to virtual number",
      input_fields: ->() {
        [
          { 
            name: "virtual_number", 
            control_type: "select", 
            pick_list: "numbers",
            label: "Virtual Number",
            hint: "Can be purchased in the NUMBERS section of your transmitsms.com account",
            optional: false
          },
        ]
      },
      type: :paging_desc,
      webhook_subscribe: lambda do |webhook_url, connection, input, recipe_id|
        get("https://api.transmitsms.com/edit-number-options.json").
          params(number: input["virtual_number"], forward_url: webhook_url)
      end,
      webhook_notification: ->(input, payload) {
        payload
      },
      webhook_unsubscribe: lambda do |webhook|
        # work in progress will be delivered in later phases
      end,
      dedup: ->(messages) {
        Time.now
      },
      output_fields: ->(object_definitions){
        object_definitions["sms_notification"]
      }
    },
    new_contact: {
      title: "New contact",
      description: "New contact added to transmitsms.com list",
      config_fields:[
        { 
        name: "list_id", 
        control_type: "select", 
        pick_list: "contactList",
        label: "Choose the contact list you want to get updates from",
        optional: false
        }
      ],
      type: :paging_desc,
      webhook_subscribe: lambda do |webhook_url, connection, input, recipe_id|
        get("https://api.transmitsms.com/set-list-callback.json").
        params(list_id: input["list_id"], url: webhook_url)
      end,
      webhook_notification: lambda do |input, payload|
        if(payload["type"] == "add")
        payload
        end
      end,
      webhook_unsubscribe: lambda do |webhook|
        # work in progress will be delivered in later phases
      end,
      dedup: ->(contact) {
        contact["mobile"]
      },
      output_fields: lambda do |object_definitions|
        object_definitions['new_contact_notification']
      end
    },
    GetSMSResponse: {
      title: 'SMS Received to Inbox',
      description: "Triggers when any new messages are found in your SMS Inbox.",
      poll: ->(connection, input) { 
        response = get("https://frontapi.transmitsms.com/zapier/get-responses.json")
          .params(page: 1, max: 10)
        {
          events: response["responses"],
          next_poll: Time.now + 600,
          can_poll_more: true
        }
      },
      dedup: lambda do |response|
        response["id"]
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['get_sms_response']
      end
    }
    
  },
  pick_lists: {
    numbers:->(connection) {
      vn = get("https://api.transmitsms.com/get-numbers.json",{
        "page": 1, "max": 100
      })
      if(vn["numbers"].present?)
        vn["numbers"].map { |number| [number["number"], number["number"]] }
      end
    },
    contactList:->(connection) {
      cl = get("https://api.transmitsms.com/get-lists.json",{
        "page": 1, "max": 100
      }) 
      if(cl["lists"].present?)
        cl["lists"].map { |contact| [contact["name"], contact["id"]] }
      end
    }
  }
}