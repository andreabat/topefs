/**
 * @author andreab
 */
    var win_preview;
    var win_orders;	
	var form_orders;
	var current_id;

	function create_order(projectitems,options /*array di elementi da associare*/){
		if (!verifyIfAllowed(projectitems,"ordered",true)) return;
		//if (!win_orders) 
		{
		win_orders = new Ext.Window({
						                    title:'Gestione Ordine',
						                    layout:'fit',
						                    width:500,
						                    height:400,
						    				animate:true,
						                  //  closeAction:'hide',
						                    plain: false,
						                    items: [
														 {
														xtype:"form",
														title:"Inserimento informazioni ordine",
														renderTo : 'add-order',
														id:'form_orders',
														frame:true,
														monitorValid:true,
														waitMsgTarget:true,
														listeners:{
															'clientvalidation':{
																	fn:function(form,valid){
																		Ext.getCmp("save_orders").setDisabled(!valid);
																	}
																}
															},
										                border:true,
														items:[
																			{
																			    xtype:"combo",
																			    fieldLabel:"Fornitore",
																				allowBlank:false,
																			    name:"order[supplier_id]",
																			    hiddenName:"order[supplier_id]",
																				mode:'local',
									    										store : new Ext.data.SimpleStore({
									    										    fields: ['supplier','id'],
									    										    data : options.suppliers
									    										}),
									    										allowBlank:false,
									    										typeAhead: true,
									    										displayField :'supplier',
									    										valueField:'id',
																				id:'supplier_id',
									    										triggerAction: 'all',
									    										resizable:true,
									    								        forceSelection:true
																			  },
																			  {
																			    xtype:"combo",
																			    fieldLabel:"Pagamento",
																			    name:"order[paymentmethod_id]",
																			    hiddenName:"order[paymentmethod_id]",
																				mode:'local',
																				allowBlank:true,
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
																			    xtype:"textfield",
																			    fieldLabel:"Oggetto",
																				allowBlank:false,
																			    name:"order[title]"
																			  },{
																			    xtype:"textarea",
																			    fieldLabel:"Referenti",
																			    name:"order[people]"
																			  }
																			  ,{
																			    xtype:"textarea",
																			    fieldLabel:"Note",
																			    name:"order[notes]"
																			  }
																			  ,{
																			    xtype:"textfield",
																			    fieldLabel:"Consegna",
																			    name:"order[delivery]"
																			  },
																			  {
																			    xtype:"numberfield",
																			    fieldLabel:"IVA",
																			    name:"order[vat]"
																			  }
															  ] // items in form
														,
									                    buttons: [
																			{
														                        text:'Crea',
														                        disabled:true,
																				type:'submit',
														    					handler:function(f){
																					
														    						save_order(projectitems,options);
														    					},
														    					id:'save_orders'
														                    },
																			
																			{
														                        text: 'Annulla',
														                        handler: function(){
														                            win_orders.close();
														                        }
									                    					}
																	] //close buttons
													}//chiudo form
													]//chiudo items
						                }); //close window creation
						            }//close if
//			Ext.getCmp("htmleditor").hide();
			win_orders.show();
		}//close func
			
	
	
	function manage_order(data,options /*array di elementi da associare*/){
		//if (!win_orders) 
		{
		win_orders = new Ext.Window({
						                    title:'Gestione Ordine',
						                    layout:'fit',
						                    width:500,
						                    height:400,
						    				animate:true,
//						                    closeAction:'hide',
						                    plain: false,
						                    items: [
														 {
														xtype:"form",
														title:"Inserimento informazioni fattura per ordine",
														renderTo : 'manage-order',
														id:'form_orders',
														frame:true,
														monitorValid:true,
														waitMsgTarget:true,
														listeners:{
															'clientvalidation':{
																	fn:function(form,valid){
																		Ext.getCmp("save_orders").setDisabled(!valid);
																	}
																}
															},
										                border:true,
														items:[ 
																			    {
																			    xtype:"checkbox",
																			    fieldLabel:"Ricevuta Fattura",
																			    name:"order[received_invoice]",
																				inputValue: '1', width: 18, height: 21
																			  }, 
																			   {
																			    xtype:"checkbox",
																			    fieldLabel:"Pagata Fattura",
																			    name:"order[payed_invoice]",
																				inputValue: '1', width: 18, height: 21
																			  },
																			  {
																			    xtype:"textfield",
																			    fieldLabel:"Importo Fattura Fornitore",
																				allowBlank:false,
																				vtype:"numeric",
																			    name:"order[amount_invoice]"
																			  }, {
																			    xtype:"datefield",
																			    fieldLabel:"Data Scadenza",
																				allowBlank:false,
																				format:'d-m-Y' , 
																				altFormats:'Y-m-d',
																			    name:"order[expires_invoice]"
																			  }
																			  ,{
																			    xtype:"textarea",
																			    fieldLabel:"Note",
																			    name:"order[notes]"
																			  },{
																					xtype: 'hidden',
																					name: "authenticity_token",
																					deferredRender:false,
																					value: options.token
																				}
																			  
															  ] // items in form
														,
									                    buttons: [
																			{
														                        text:'Salva',
														                        disabled:true,
																				type:'submit',
														    					handler:function(f){
																					
														    						update_order(data,options);
														    					},
														    					id:'save_orders'
														                    },
																			
																			{
														                        text: 'Annulla',
														                        handler: function(){
														                            win_orders.close();
														                        }
									                    					}
																	] //close buttons
													}//chiudo form
													]//chiudo items
						                }); //close window creation
						            }//close if
//			Ext.getCmp("htmleditor").hide();
			win_orders.show();
			Ext.getCmp("form_orders").getForm().loadRecord(data);
		}//close func
			
		function update_order(data,options){
			form_orders=Ext.getCmp("form_orders");
			//form_orders.getForm().updateRecord(data);
			form_orders.getForm().submit({
				waitMsg:"Salvataggio in corso",
				url: '/orders/update/' + data.id,
				params: {
					_method: 'POST'
				},
				success: function(a, b, c){
					Ext.Msg.alert('Status', 'Creato.', function(){
						form_orders.getForm().reset();
						win_orders.close();
						order_datastore.load();
					})
				},
				failure: function(a, b, c){
					if (b.result) {
						Ext.Msg.alert('System', 'Errore di sistema:' + $H(b.result.errors).values().join('<br>'));
					}
					else 
						Ext.Msg.alert('System', 'Errore di sistema:' + b.response.responseText);
				}
				
			})
			
			
		}
 
		
		function save_order(projectitems, options){
   		  form_orders=Ext.getCmp("form_orders");
			projectitems.each(function(r, i){
				form_orders.add({
					xtype: 'hidden',
					deferredRender:false,
					name: "projectitem[" + i + "]",
					value: r.get('id')
				});
			});
			
			form_orders.add({
				xtype: 'hidden',
				name: "authenticity_token",
				deferredRender:false,
				value: options.token
			});
			form_orders.add({
				xtype: 'hidden',
				name: "order[project_id]",
				deferredRender:false,
				value: options.project_id
			});
			
//			form_orders.add({
//				xtype: 'hidden',
//				name: "order[budget_id]",
//				deferredRender:false,
//				value: options.budget_id
//			});
			
			form_orders.doLayout();
			form_orders.getForm().submit({
				waitMsg:"Salvataggio in corso",
				url: '/orders/create',
				params: {
					_method: 'POST'
				},
				success: function(a, b, c){
					Ext.Msg.alert('Status', 'Ordine generato.Cliccare su OK per generare il file.', function(){
						//prendi il valore di ritorno dell'id
						current_id=b.result.id;
//						Ext.getCmp("htmleditor").show();
//						Ext.getCmp("htmleditor").setValue(b.result.html);
//						Ext.getCmp("form_orders").hide();
						window.open("/orders/edit/"+current_id + ".odt");
						//should issue reload ?
						form_orders.getForm().reset();
						gs.load();
						win_orders.close();
					})
				},
				failure: function(a, b, c){
					if (b.result) {
						Ext.Msg.alert('System', 'Errore di sistema:' + $H(b.result.errors).values().join('<br>'));
					}
					else 
						Ext.Msg.alert('System', 'Errore di sistema:' + b.response.responseText);
				}
				
			})
		}

		
function delete_order(data,size){
		
		
		Ext.Ajax.request({
									  	url:"/orders/" +  data.id + ".ext_json",
										method: 'DELETE',
										success:function(a,b,c){
											var o = Ext.decode(a.responseText);
											alert(o.msg);
											order_datastore.load({
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