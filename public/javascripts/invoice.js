/**
 * @author andreab
 */
    var win_invoice;
	var win_proceeds,frm_proceeds;
	
	var proc_mgr;
	
	function add_proceed(i,p){
		if (!win_proceeds) {
		frm_proceeds = new Ext.form.FormPanel({
				frame: true,
				autoScroll: true,
				autoHeight:true,
				autoWidth:true,
				monitorValid: true,
				waitMsgTarget: true,
				items: [
				{
					name:"pippo",
					labelSeparator:"",
					hidden:true
					
				},
				{
					xtype: "numberfield",
					fieldLabel: "Incasso",
					name: "proceed[amount]"
					
				},
				{
					xtype: "datefield",
					fieldLabel: "Data",
					format:"d-m-Y",
					name: "proceed[date]",
					altFormats:"Y-m-d",
					value:new Date().format("d-m-Y")
				} ,
				{
					xtype: "hidden",
					name: "proceed[invoice_id]",
					id:"proceed_invoice_id"
				},
				{
					xtype: "hidden",
					name: "proceed[project_id]",
					id:"proceed_project_id"
				}
				 
				],
				buttons:[{text:"ok",type:'submit',
				
				
					handler:function(){
					//action per il salvataggio..
					frm_proceeds.getForm().submit({
																			success:function(a,b,c){
																					Ext.Msg.alert("Status","Dato creato.")
																					frm_proceeds.getForm().reset(); win_proceeds.hide();
																					Ext.getCmp("proceed-grid").store.reload();
																					//var o = Ext.decode(a.responseText);
																					[ "income" ].each(function(f){
																						$("proceed-" +f).update(Ext.util.Format.euroMoney(b.result[f]));
																					})
																					
																					
																					
																					
				  																	},
																			failure:function(a,b,c){
																					frm_proceeds.getForm().reset(); frm_proceeds.hide()
																					if(b.result)
																					{
																						Ext.Msg.alert("System","Errore di sistema:" + $H(b.result.errors).values().join("\n"));
																					}
																					else
																						Ext.Msg.alert("System","Errore di sistema:" + b.response.responseText);
																			},
																			url:'/proceeds/create?format=ext_json', 
																			waitMsg:'Salvataggio in corso'
																		}); 
					
					}}]
			
			});	
		win_proceeds = new Ext.Window({
			title: "Inserimento Ricavo per la fattura ",
			width:450,
			id:"win-proceed",
			height:135,
			animateTarget:"proceed-grid",
			closeAction:"hide",
			items:[frm_proceeds]
			
		})
		
			//frm_proceeds.render("show-proceeds")
		}
		 
		frm_proceeds.findById("proceed_invoice_id").setValue(i);
		frm_proceeds.findById("proceed_project_id").setValue(p);
		win_proceeds.show();
	}
	
	function show_proceeds(c,t){

	//	if(!proc_mgr)proc_mgr = new Ext.Updater("info-hotspot");
	if (parent.add_tab) {
	 
		parent.add_tab("/proceeds/index?&invoice_id=" + c, 'Dettaglio fattura ' + t);
	}else
	{
		window.open ("/proceeds/index?&invoice_id=" + c, 'Dettaglio fattura ' + t);
	}
	

return;
		//proc_mgr.update("/proceeds/index?&invoice_id=" +c );
		if(!proc_mgr){
			proc_mgr = new Ext.ux.ManagedIframePanel({
								defaultSrc:"/proceeds/index?&invoice_id=" +c ,
								loadMask:true,
								text:'Caricamento dettagli fattura',
								closable:false,
								
								 width:      570,
				                height:380,
								collapsible:true,
								renderTo:"info-hotspot",
								title:"Dettaglio Fattura"
							})  
					proc_mgr.on("documentloaded",function(){invoice_datastore.load()})
		}else
			proc_mgr.setSrc("/proceeds/index?&invoice_id=" +c);

	}
	function create_invoice(projectitems,options /*array di elementi da associare*/){
		 if (!verifyIfAllowed(projectitems,"invoiced",true)) return;
		//if (!win_invoice) 
		{
		
		win_invoice = new Ext.Window({
						                    title:'Gestione Fattura',
						                    layout:'fit',
						                    width:500,
						                    height:400,
						    				animate:true,
//						                    closeAction:'hide',
						                    plain: false,
						                    items: [
														  
														 
														 {
														xtype:"form",
														title:"Inserimento informazioni Fattura",
														renderTo : 'add-invoice',
														id:'form_invoice',
														frame:true,
														autoScroll:true,
														monitorValid:true,
														waitMsgTarget:true,
														listeners:{
															'clientvalidation':{
																	fn:function(form,valid){
																		Ext.getCmp("save_invoice").setDisabled(!valid);
																	}
																}
															},
										                border:true,
														items:[
																			    
																			  {
																			    xtype:"textfield",
																			    fieldLabel:"Oggetto",
																				allowBlank:false,
																				id:'invoice_subject',
																			    name:"invoice[title]",
																				width:200
																			  },{
																			    xtype:"combo",
																			    fieldLabel:"Pagamento",
																			    name:"invoice[paymentmethod_id]",
																			    hiddenName:"invoice[paymentmethod_id]",
																				mode:'local',
																				allowBlank:false,
									    										store : new Ext.data.SimpleStore({
									    										    fields: ['payment','id'],
									    										    data : options.paymentmethods
									    										}),
									    										typeAhead: true,
									    										displayField :'payment',
									    										valueField:'id',
									    								        forceSelection:true
																			  },
																			  {
																			    xtype:"numberfield",
																			    fieldLabel:"IVA",
																			    name:"invoice[vat]",
																				value:"20"
																			  },
																			  /*{
																			    xtype:"numberfield",
																			    fieldLabel:"Sconto",
																			    name:"invoice[discount]"
																			  },*/
																			  {
																			    xtype:"textarea",
																			    fieldLabel:"Referenti",
																			    name:"invoice[people]",
																				anchor:'60%',
																				preventScrollbars:false,
																				style:"height:50px;"
																			  }
																			  ,{
																			    xtype:"textarea",
																			    fieldLabel:"Note",
																			    name:"invoice[notes]",
																				anchor:'60%',
																				preventScrollbars:false,
																				style:"height:50px;"
																			  }
																			  ,{
																			    xtype:"textfield",
																			    fieldLabel:"Consegna",
																			    name:"invoice[delivery]"
																			  },{
																			    xtype:"textarea",
																			    fieldLabel:"Coordinate Bancarie",
																			    name:"invoice[bank]",
																				value:options.bank,
																				anchor:'60%',
																				preventScrollbars:false,
																				style:"height:50px;"
																			  }
																			  
																			  
															  ] // items in form
														,
									                    buttons: [
																			{
														                        text:'Crea',
														                        disabled:true,
																				type:'submit',
														    					handler:function(f){
																					
														    						save_invoice(projectitems,options);
														    					},
														    					id:'save_invoice'
														                    },
																			
																			{
														                        text: 'Annulla',
														                        handler: function(){
														                            win_invoice.close();
														                        }
									                    					}
																	] //close buttons
													}//chiudo form
													]//chiudo items
						                }); //close window creation
						            }//close if

			win_invoice.show();
			win_invoice.findById("invoice_subject").setValue(options.title)
		}//close func
			
		
	
		
		 
		function verifyIfAllowed(items,field,value){
			var valid = true;

			items.each(function(r){
				if (r.get(field)==value){
					valid=false;
					return false;
				}
			});
			if (!valid){
				Ext.Msg.alert("Errore","Impossibile creare una fattura/ordine/preventivo con un elemento già precedentemente fatturato/ordinato/preventivato.\nEventualmente disdire la fattura/ordine a cui è associato");
				return false;
			}
			return true;
		}
		
		function save_invoice(projectitems, options){
		  
   		  p=Ext.getCmp("form_invoice");
		//options.from mi specifica se devo copiare da pricing
		  if (!options.from_pricing) {
		  	projectitems.each(function(r, i){
		  		p.add({
		  			xtype: 'hidden',
		  			deferredRender: false,
		  			name: "projectitem[" + i + "]",
		  			value: r.get('id')
		  		});
		  	});
		  }
			p.add({
				xtype: 'hidden',
				name: "authenticity_token",
				deferredRender:false,
				value: options.token
			});
			p.add({
				xtype: 'hidden',
				name: "invoice[project_id]",
				deferredRender:false,
				value: options.project_id
			});
			
			 
			
//			p.add({
//				xtype: 'hidden',
//				name: "invoice[budget_id]",
//				deferredRender:false,
//				value: options.budget_id
//			});
			
			p.doLayout();
			
			var url;
			if (options.from_pricing) 
				url=options.from_pricing;
			else
				url = '/invoices/create'
				
			p.getForm().submit({
				waitMsg:"Salvataggio in corso",
				url: url,
				params: {
					_method: 'POST'
				},
				success: function(a, b, c){
					Ext.Msg.alert('Status', 'La fattura è stata generata.Cliccare su OK per generare il file.', function(c,d,e){
						//prendi il valore di ritorno dell'id
						var o = Ext.decode(b.responseText)
						current_id=b.result.id;
						parent.add_tab("/invoices/edit/"+current_id + ".odt","Fattura " + b.result.code)
					 	    //window.open();
						p.getForm().reset();
						gs.load();
//						gs.getById(current_id).set("invoiced",true);
						win_invoice.close();
					})
				},
				failure: function(a, b, c){
					if (b.result) {
						Ext.Msg.alert('System', 'Errore di sistema:' + b.result.errors.join('<br>'));
					}
					else 
						Ext.Msg.alert('System', 'Errore di sistema:' + b.response.responseText);
				}
				
			})
		}

		function invoice_payed(id,obj){
			 var dop = new Ext.Window({
                title: 'Inserire la Data ',
				animateTarget:obj,
				width:250,
				id:"win-pa",
				closeAction:"close",
				height:150,
                items: [{
                    xtype: "datefield",
                    id: 'dp_ordini',
					
                    format: 'd-m-Y',
                    altFormats: 'Y-m-d',
                    value: new Date().format("d-m-Y")
                }],
                buttons: [{
                    text: "salva",
                    handler: function(f, b){
                        if (Ext.getCmp("dp_ordini").validate()) {
                            Ext.Ajax.request({
				              method: 'GET',
				        		url: "/invoices/payed/" + id  + "?date=" + Ext.getCmp("dp_ordini").getValue().format("Y-m-d")
								 
							    });
                            window.location.reload();
                        }
                    }
                }]
            
            
            });
			dop.show();
			
			
		
		}
		
		function invoice_not_payed(id){
			Ext.Ajax.request({
              method: 'GET',
        		url: "/invoices/not_payed/" + id 
			    });
				window.location.reload();
		}

		
		function delete_invoice(data,size){
		
		
		Ext.Ajax.request({
									  	url:"/invoices/" +  data.id + ".ext_json",
										method: 'DELETE',
										success:function(a,b,c){
											var o = Ext.decode(a.responseText);
											alert(o.msg);
											invoice_datastore.load({
					                          params: { 
					                                    start:0, 
					                                    limit:size ,
					                                    fields:'',
					                                    query:''
					                                    
					                                    }
					                        });
										},
										failure:function(){
											alert("error")
										}
									  })
		
		
		
}

