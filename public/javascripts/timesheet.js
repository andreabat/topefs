var timesheet_store;
var projects_store;
var project_current_id;
var project_token;
var timesheet_form_url = "/timesheet/create";
function timesheet_setup(options){
    projects_store = options.projects;
    project_current_id = options.project_id;
    project_token = options.token;
    timesheet_store = new Ext.data.JsonStore({
        url: '/timesheet/',
		baseParams:{format:'ext_json'},
        root: 'timesheets',
        id: 'id',
        fields: ['id', {
            name: 'hours',
            type: 'float'
        }, {
            name: 'title',
            mapping: 'project.title'
        }, {
            name: 'notes'
        }]
    });
    
    
    var tpl = new Ext.XTemplate('<tpl for=".">', '<div id="hours_{id}">', '<fieldset><a href="#" onclick="timesheet_modifica({id})">modifica</a>|<a onclick="timesheet_elimina({id})" href="#">elimina</a>', '<br><b>Progetto</b>:{title}<br><b>Ore lavorate</b>:{hours}<br>', '<b>Note</b>:{notes}<br></fieldset>', '</div><hr>', '</tpl>');
    
    var dp = new Ext.DatePicker({
        applyTo: 'date-picker',
		width:175
		
    });
    dp.on("select", date_selected);
    var pd = new Ext.Panel({
        applyTo: 'date-timesheet-detail',
        frame: true,
        autoScroll: true,
        height: 500,
        id: 'date-timesheet-detail',
        title: "Ore lavorate",
        items: new Ext.DataView({
            store: timesheet_store,
            tpl: tpl,
            loadingText: 'Caricamento in corso',
            autoHeight: true,
            multiSelect: true,
            overClass: 'x-view-over',
            itemSelector: 'div.thumb-wrap',
            emptyText: 'Nessuna attività per il giorno'
        })
    });
    
}

function date_selected(c, d){
    //Allora ?
    var ts = Ext.getCmp("timesheet-form");
    Ext.getCmp('date-timesheet-detail').setTitle("Ore lavorate per il giorno " + d.format('d/m/Y'))
    if (!ts) {
        ts = new Ext.form.FormPanel({
            title: "Inserimento Timesheet",
            renderTo: 'date-timesheet-add',
            id: 'timesheet-form',
            frame: true,
            autoScroll: true,
            monitorValid: true,
            waitMsgTarget: true,
            listeners: {
                'clientvalidation': {
                    fn: function(form, valid){
                        Ext.getCmp("save_timesheet").setDisabled(!valid);
                    }
                }
            },
            border: true,
            items: [{
                xtype: 'hidden',
                name: "authenticity_token",
                deferredRender: false,
                value: project_token
            },{
                xtype: 'hidden',
                name: "timesheet[id]",
				id : 'useful_id',
                deferredRender: false,
                value: null
            }, {
                xtype: "datefield",
                allowBlank: false,
				labelSeparator:'',
                id: 'timesheet_date',
                hidden: true,
				
                format: 'Y-m-d',
                name: "timesheet[date]",
                width: 50
            }, {
                xtype: "numberfield",
                fieldLabel: "Ore lavorate",
                maxLength: 3,
				id:'timesheet_hours',
                allowBlank: false,
                name: "timesheet[hours]",
                width: 50
            }, {
                fieldLabel: 'Progetti',
                xtype: "combo",
                mode: 'local',
                store: new Ext.data.SimpleStore({
                    fields: ['project', 'id'],
                    data: projects_store
                }),
                allowBlank: false,
                typeAhead: true,
                displayField: 'project',
                valueField: 'id',
                id: 'project_id',
                triggerAction: 'all',
                disabled: project_current_id!="",
                hiddenName: 'timesheet[project_id]',
                name: 'timesheet[project_id]',
                resizable: true,
                forceSelection: true
            }, {
                fieldLabel: 'Note',
                xtype: 'textarea',
				id:'timesheet_notes',
                name: "timesheet[notes]"
            }],
            buttons: [{
                text: 'Ok',
                disabled: true,
                type: 'submit',
                handler: function(f){
                    save_timesheet(ts.getForm());
                },
                id: 'save_timesheet'
            }]
        });
        
    }//if ts
    ts.findById("project_id").setValue(project_current_id);
	
    ts.findById("timesheet_date").setValue(d);
	ts.setTitle("Inserimento Timesheet per il giorno " + d.format('d/m/Y') )
    timesheet_store.load({
        params: {
            d: d.format('Y-m-d'),
            _method: 'GET'
        }
    })
}


function save_timesheet(f){
    Ext.getCmp("project_id").enable();
    
    f.submit({
        waitMsg: "Salvataggio Timesheet in corso",
        url: timesheet_form_url + (timesheet_form_url=='/timesheet/create' ?'':"/" + Ext.getCmp("useful_id").getValue()),
        params: {
            _method: timesheet_form_url=='/timesheet/create' ?'POST':'PUT'
        },
        success: function(a, b, c){
            Ext.Msg.alert('Status', 'Ok.', function(){
                //prendi il valore di ritorno dell'id
				if(project_current_id!="")
	                Ext.getCmp("project_id").disable();
				timesheet_form_url = "/timesheet/create";
                timesheet_refresh();
				
            })
        },
        failure: function(a, b, c){
			if(project_current_id!="")
            	Ext.getCmp("project_id").disable();
			timesheet_form_url = "/timesheet/create";
            if (b.result) {
                Ext.Msg.alert('System', 'Errore di sistema:' + $H(b.result.errors).values().join('<br>'));
            }
            else 
                Ext.Msg.alert('System', 'Errore di sistema:' + b.response.responseText);
        }
    })
}

function timesheet_modifica(id){
    //creo un nuovo record
    var r = {
        data: {}
    }
    timesheet_form_url = "/timesheet/update";
    for (h in timesheet_store.getById(id).data) {
        r.data["timesheet[" + h + "]"] = timesheet_store.getById(id).data[h];
        
    }
    Ext.getCmp('timesheet-form').getForm().loadRecord(r);
    
}

function timesheet_elimina(id){
    //creo un nuovo record
    Ext.Ajax.request({
        params: {
            authenticity_token: project_token
        },
        method: 'DELETE',
        url: "/timesheet/destroy/?data=" + id
    });
    timesheet_form_url = "/timesheet/create";
    timesheet_refresh()
}

function timesheet_refresh(){

	var ts = Ext.getCmp('timesheet-form');
	ts.findById("timesheet_hours").setValue("");
	ts.findById("timesheet_notes").setValue("");
	ts.findById("useful_id").setValue(null);
	
    timesheet_store.load({
        params: {
            _method: 'GET',
            d: Ext.getCmp("timesheet_date").getValue().format('Y-m-d')
        }
    });
}
