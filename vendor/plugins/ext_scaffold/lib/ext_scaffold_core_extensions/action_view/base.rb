module ExtScaffoldCoreExtensions
  module ActionView
    module Base

      def ext_grid_for(object_name, options = {})
        element = options[:element]
        datastore = options[:datastore] || "#{object_name}_datastore"
        offset = params[:start] || (controller.send(:previous_pagination_state, object_name))[:offset] || 0
        page_size = options[:page_size] || 5
        column_model = options[:column_model] || "#{object_name}_column_model"
        collection_path_method = "#{object_name.to_s.pluralize}_path"
        collection_path = send collection_path_method
        new_member_path = send "new_#{object_name}_path"
        panel_title = options[:title] || "Listing #{object_name.to_s.titleize.pluralize}"
        fields = options[:fields] || ""
        query  = options[:query] || ""
       # frame_scope = options[:frame_scope]
        edit_handler = options[:edit_handler]||"window.location.href = '#{collection_path}/' + selected.data.id + '/edit';"
        add_handler = options[:add_handler]||"window.location.href = '#{new_member_path}';"
        dbl_handler  = options[:dbl_handler]||"window.location.href = '#{collection_path}/' + grid.getStore().getAt(row).id;"
        
        javascript_tag <<-_JS
          Ext.onReady(function(){

              Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
              Ext.QuickTips.init();

              var ds = #{datastore};

              var cm = #{column_model};
              cm.defaultSortable = true;

              // create the grid
              var grid = new Ext.grid.GridPanel({
                  ds: ds,
                  cm: cm,
                  loadMask:true,
                  sm: new Ext.grid.RowSelectionModel({singleSelect:true}),
                  renderTo:   '#{element}',
                  title:      '#{panel_title}',
                  id:         #{options[:id] || :null},
                  width:      #{options[:width] || 540},
                  height:     #{options[:height] || 208},
                  stripeRows: #{options[:stripe_rows] == false ? 'false' : 'true'},
                  viewConfig: {
                      forceFit:#{options[:force_fit] == false ? 'false' : 'true'}
                  },

                  // inline toolbars
                  tbar:[{
                      text:'#{:grid_new.l}',
                      tooltip:'Create new #{object_name.to_s.humanize}',
                      handler: function(){#{add_handler}},
                      iconCls:'add'
                  }, '-', {
                      text:'#{:grid_edit.l}',
                      tooltip:'Edit selected #{object_name.to_s.humanize}',
                      handler: function(){
                                 var selected = grid.getSelectionModel().getSelected();
                                 if(selected) {
                                   #{edit_handler}
                                 } else { 
                                   alert('#{:grid_select_row.l}');
                                 }
                               },
                      iconCls:'edit'
                  },'-',{
                      disabled:true,
                      text:'Delete...',
                      tooltip:'Delete selected #{object_name.to_s.humanize}',
                      handler: function(){
                                 var selected = grid.getSelectionModel().getSelected();
                                 if(selected) {
                                   if(confirm('Really delete?')) {
                                      var conn = new Ext.data.Connection();
                                      conn.request({
                                          url: '#{collection_path}/' + selected.data.id,
                                          method: 'POST',
                                          params: { _method: 'DELETE',
                                                    #{request_forgery_protection_token}: '#{form_authenticity_token}'
                                                  },
                                          success: function(response, options){ ds.load(); },
                                          failure: function(response, options){ alert('Delete operation failed.'); }
                                      });
                                   }
                                 } else { 
                                   alert('#{:grid_select_row.l}');
                                 }
                               },
                      iconCls:'remove'
                  },'->'],
                  bbar: new Ext.PagingToolbar({
                            pageSize: #{page_size},
                            store: ds,
                            displayInfo: true,
                            displayMsg: 'Record {0} - {1} of {2}',
                            emptyMsg: '#{:grid_no_records.l}'
                  })
                  #{",plugins:[new Ext.ux.grid.Search({position:'top'})]" unless options[:plugin].nil?}
              });

              // show record on double-click
              #{"grid.on('rowdblclick', function(grid, row, e) {
                #{dbl_handler}
              });" unless options[:nodblclick]}
              ds.baseParams={fields:'#{fields}',query:'#{query}'}
              ds.load({
                          params: { 
                                    start: #{offset}, 
                                    limit:#{page_size} ,
                                    fields:'#{fields}',
                                    query:'#{query}'
                                    
                                    }
                        });

          });
        _JS
      end

      def ext_form_for(object_name, options = {})
        element = options[:element]
        object = options[:object] || instance_variable_get("@#{object_name}")
        mode = options[:mode] || :edit
        form_items = options[:form_items] || '[]'
        member_path_method = "#{object_name}_path"
        collection_path_method = "#{object_name.to_s.pluralize}_path"
        collection_path = send collection_path_method
        form_title = options[:title] || "#{ {:show => 'Showing', :edit => 'Edit', :new => 'Create'}[options[:mode]]} #{object_name.to_s.humanize}"
        save_callback = options[:save_callback]|| "function(){document.location='#{collection_path}';}"
        javascript_tag <<-_JS  
          Ext.onReady(function(){

              Ext.QuickTips.init();

              // turn on validation errors beside the field globally
              Ext.form.Field.prototype.msgTarget = 'side';

              var panel = new Ext.FormPanel({
                  labelWidth:   75, // label settings here cascade unless overridden
                  url:          '#{collection_path}',
                  frame:         true,
                  waitMsgTarget: true,
                  title:         '#{form_title}',
                  bodyStyle:     'padding:5px 5px 0',
                  width:         350,
                  monitorValid:   true,
                  defaults:      {width: 230},
                  defaultType:   'textfield',
                  renderTo:      '#{element}',
                  listeners:{
                   
                                'actionfailed':{
                                  fn:function(f,ok){
                                  }
                                },
                                'clientvalidation':{
                                    fn:function(f,ok){
                                      var o  =Ext.getCmp("save_btn");
                                      ok?o.enable():o.disable();
                                    }
                                  } 
                            },
                  baseParams:    {#{request_forgery_protection_token}: '#{form_authenticity_token}'},
                  items: #{form_items},

                  buttons: [ #{ext_button(:text => :l_save.l, :type => 'submit',:id=>'save_btn', 
                                          :handler => ( (mode == :edit||mode==:new) ?
                                            "function(){ panel.form.submit({url:'#{send member_path_method, object, :format => :ext_json}', params:{ _method:'#{'PUT' if mode==:edit}#{'POST' if mode==:new}' },
                                             success:function(a,b,c){
                                                    Ext.Msg.alert('Status','#{:created.localize} ', #{save_callback} )
                                                  },
                                            failure:function(a,b,c){
                                                var msg;
                                                if(b.result)
                                                  msg = b.result.errors.join('<br>');
                                                else
                                                 msg = b.response.responseText;
                                                 Ext.Msg.show({
                                                  title: 'System',
                                                  msg: '#{:sys_error.l} ' +msg,
                                                  icon: Ext.MessageBox.ERROR
                                                });
                                            },
                                             waitMsg:'#{:saving.localize}...'}); }" :
                                            "function(){ panel.form.submit({url:'#{send collection_path_method, :format => :ext_json}', waitMsg:'Saving...'}); }")) unless mode == :show}
                                           #{"," <<  ext_button(:text => :l_back.l , :handler => options[:over_back]||"function(){ window.location.href = '#{collection_path}'; }") unless options[:noback]}
                                           
                           ]
              });

              // populate form values
              panel.form.setValues(#{object.to_ext_json(:output_format => :form_values)});

              // disable items in show mode
              #{"panel.form.items.each(function(item){item.disable();});" if mode == :show}
          });
        _JS
      end

      def ext_datastore_for(object_name, options = {})
        collection_path_method = "#{object_name.to_s.pluralize}_path"
        datastore_name = options[:datastore] || "#{object_name}_datastore"
        primary_key = object_name.to_s.classify.constantize.primary_key
        javascript_tag <<-_JS  
          var #{datastore_name} = new Ext.data.Store({
                  proxy: new Ext.data.HttpProxy({
                             url: '#{send collection_path_method, :format => :ext_json}',
                             method: 'GET'
                         }),
                  reader: new Ext.data.JsonReader({
                              root: '#{object_name.to_s.pluralize}',
                              id: '#{primary_key}',
                              totalProperty: 'results'
                          },
                          [ {name: 'id', mapping: '#{primary_key}'}, #{attribute_mappings_for object_name, :skip_id => true} ]),
                  // turn on remote sorting
                  remoteSort: true,
                  sortInfo: {field: '#{options[:sort_field] || primary_key}', direction: '#{options[:sort_direction] || "ASC"}'}
              });
              function refresher(){
                      #{datastore_name}.load({
                                                          params: {start: 0, limit:5}
                                                          });
                                          }
              
        _JS
      end

      # this helper is meant to be called within a javascript_tag
      # NOTE: possible refactoring into ext_form_items_for + private ext_field method
      #       (similar to ext_datastore_for)
      def ext_field(options)
        rails_to_ext_field_types = {
          'text_field'      => 'textfield',
          'datetime_select' => 'xdatetime', # custom class
          'date_select'     => 'datefield',
          'text_area'       => 'textarea',
          'check_box'       => 'checkbox'
        }
        options[:xtype] = rails_to_ext_field_types[options[:xtype].to_s] || options[:xtype]
        js =  "{"
        js << "  fieldLabel: '#{options[:field_label]}',"
        js << "  allowBlank: #{options[:allow_blank] == false ? 'false' : 'true'}," unless options[:allow_blank].nil?
        js << "  vtype: '#{options[:vtype]}'," if options[:vtype]
        js << "  xtype: '#{options[:xtype]}'," if options[:xtype]
        js << "  format: 'Y/m/d'," if options[:xtype] == 'datefield' && !options[:format]
        js << "  format: '#{options[:format]}'," if options[:format]
        js << "  altFormats: '#{options[:altFormats]}'," if options[:altFormats]
        js << "  maxLength: '#{options[:max_length]}'," unless options[:max_length].nil?        
        js << "  disabled: '#{options[:disabled]}'," unless options[:disabled].nil?
        js << "  dateFormat: 'Y/m/d', timeFormat: 'H:i:s'," if options[:xtype] == 'xdatetime'
        js << "  inputValue: '1', width: 18, height: 21," if options[:xtype] == 'checkbox'
        js << "  name: '#{options[:name]}'"
        js << "}"
        if options[:xtype] == 'checkbox'
          js << ",{"
          js << "   xtype: 'hidden',"
          js << "   value: '0',"
          js << "   name: '#{options[:name]}'"
          js << " }"
        end

        js
      end

      private

        def attribute_mappings_for(object_name, options = {})
          object_class = object_name.to_s.classify.constantize
          requested_attributes = object_class.column_names.reject {|c| options[:skip_id] && c == object_class.primary_key}
          requested_attributes.collect {|c| "{name: '#{object_name}[#{c}]', mapping: '#{c}'}" }.join(',')
        end

        def ext_button(options)
          js =  "{"
          js << "  id: '#{options[:id]}',"
          js << "  text: '#{options[:text]}',"
          js << "  type: '#{options[:type]}'," if options[:type]
          js << "  handler: #{options[:handler]}"
          js << "}"
        end

    end
  end
end