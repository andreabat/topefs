Ext.BLANK_IMAGE_URL = '/images/ext/resources/images/default/s.gif';
Ext.onReady(function() {
    Ext.QuickTips.init();
    Ext.form.Field.prototype.msgTarget = 'side';
	Ext.state.Manager.setProvider(new Ext.state.CookieProvider);

	var themeCombo = new Ext.ux.ThemeCombo({renderTo:'comboct', width:140});

	// window with uploadpanel
    var win = new Ext.Window({
         width:180
		,minWidth:165
        ,id:'winid'
        ,height:220
		,minHeight:200
        ,layout:'fit'
        ,border:false
        ,closable:false
        ,title:'UploadPanel'
		,iconCls:'icon-upload'
		,items:[{
			  xtype:'uploadpanel'
			 ,buttonsAt:'tbar'
			 ,id:'uppanel'
			 ,url:'filetree.php'
			 ,path:'root'
			 ,maxFileSize:1048576
//			 ,enableProgress:false
			 ,singleUpload:true
		}]
    });
    win.show();

	var treepanel = new Ext.ux.FileTreePanel({
		 width:240
		,height:400
		,id:'ftp'
		,title:'FileTreePanel'
		,renderTo:'treepanel'
		,rootPath:'root'
		,topMenu:true
		,autoScroll:true
		,enableProgress:false
		,singleUpload:true
	});

});

