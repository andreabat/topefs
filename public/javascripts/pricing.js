/**
 * @author andreab
 */
    var win_pricing;
//    var current_pricing_items;
	function create_pricing(pricingitems,options /*array di elementi da associare*/){
//		current_pricing_items=pricingitems;
		if (!verifyIfAllowed(pricingitems,"priced",true)) return;
	//	if (!win_pricing) 
	{
		 
		win_pricing = new Ext.Window({
						                    //el:'pricing-win',
											title:"Creazione preventivo",
						                    layout:'fit',
						                    width:500,
						                    height:400,
						    				animate:true,
						                   // closeAction:'hide',
						                    plain: false,
						                    items: [
														 {
														xtype:"form",
														title:"Inserimento informazioni preventivo",
														renderTo : 'add-pricing',
														id:'form_pricing',
														frame:true,
														monitorValid:true,
														waitMsgTarget:true,
														listeners:{
															'clientvalidation':{
																	fn:function(form,valid){
																		Ext.getCmp("save_pricing").setDisabled(!valid);
																	}
																}
															},
										                border:true,
														items:[
																			    
																			  {
																			    xtype:"textfield",
																			    fieldLabel:"Oggetto",
																				allowBlank:false,
																				id:'pricing_subject',
																			    name:"pricing[title]",
																				width:200
																			  },{
																			    xtype:"combo",
																			    fieldLabel:"Pagamento",
																			    name:"pricing[paymentmethod_id]",
																			    hiddenName:"pricing[paymentmethod_id]",
																				mode:'local',
									    										store : new Ext.data.SimpleStore({
									    										    fields: ['payment','id'],
									    										    data : options.paymentmethods
									    										}),
									    										typeAhead: true,
									    										displayField :'payment',
									    										valueField:'id',
																				id:'paymentmethod_id',
									    										triggerAction: 'all',
									    										resizable:true,
									    								        forceSelection:true
																			  },
																			  {
																			    xtype:"textfield",
																			    fieldLabel:"Sconto",
																			    name:"pricing[discount]",
																				id :"pricing[discount]",
																				value:0,
																				vtype:'numeric',
																				decimalSeparator:","
																			  },
																			  {
																			    xtype:"textarea",
																			    fieldLabel:"Referenti",
																			    name:"pricing[people]"
																			  }
																			  ,{
																			    xtype:"textarea",
																			    fieldLabel:"Note",
																			    name:"pricing[notes]"
																			  },{
																			    xtype:"textfield",
																			    fieldLabel:"Fatturazione",
																			    name:"pricing[invoicing]"
																			  } 
																			  ,{
																			    xtype:"textfield",
																			    fieldLabel:"Consegna",
																			    name:"pricing[delivery]"
																			  }
																			  
															  ] // items in form
														,
									                    buttons: [
																			{
														                        text:'Crea',
														                        disabled:true,
																				type:'submit',
														    					handler:function(f){

														    						save_pricing(pricingitems,options);
														    					},
														    					id:'save_pricing'
														                    },
																			
																			{
														                        text: 'Annulla',
														                        handler: function(){
														                            win_pricing.close();
														                        }
									                    					}
																	] //close buttons
													}//chiudo form
													]//chiudo items
						                }); //close window creation
						            }//close if

			win_pricing.show();
			win_pricing.findById("pricing_subject").setValue("PREVENTIVO " + options.title)
		}//close func
			
		
	
		
		 
		
		
		function save_pricing(projectitems, options){
   		  p=Ext.getCmp("form_pricing");
		 // remove_hiddens(p);
			projectitems.each(function(r, i){
				p.add({
					xtype: 'hidden',
					deferredRender:false,
					name: "projectitem[" + i + "]",
					value: r.get('id')
				});
			});
			
			p.add({
				xtype: 'hidden',
				name: "authenticity_token",
				deferredRender:false,
				value: options.token
			});
			p.add({
				xtype: 'hidden',
				name: "pricing[project_id]",
				deferredRender:false,
				value: options.project_id
			});
			

			p.doLayout();
			if (Ext.getCmp("pricing[discount]").value==""){
				Ext.getCmp("pricing[discount]").setValue(0);
			}
			Ext.getCmp("pricing[discount]").setValue(Ext.getCmp("pricing[discount]").getValue().replace(",","."));
			p.getForm().submit({
				clientValidation:false,
				waitMsg:"Salvataggio in corso",
				url: '/pricings/create',
				params: {
					_method: 'POST'
				},
				success: function(a, b, c){
					Ext.Msg.alert('Status', 'Il preventivo è stato generato.Cliccare su OK per generare il file.', function(){
						//prendi il valore di ritorno dell'id
						current_id=b.result.id;
					 	window.open("/pricings/edit/"+current_id + ".odt");
						gs.load();
						p.getForm().reset();
						win_pricing.close();
					})
				},
				failure: function(a, b, c){
					if (b.result) {
						Ext.Msg.alert('System', 'Errore di sistema:' + $H(b.result.errors).values().join('<br>'));
					}
					else {
						Ext.Msg.alert('System', 'Errore di sistema:' + b.response.responseText);
					}
				}
				
			});
		}



function delete_pricing(data,size){
		
		
		Ext.Ajax.request({
									  	url:"/pricings/" +  data.id + ".ext_json",
										method: 'DELETE',
										success:function(a,b,c){
											var o = Ext.decode(a.responseText);
											alert(o.msg);
											pricing_datastore.load({
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