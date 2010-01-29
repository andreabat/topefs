// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
Ext.form.VTypes["phoneVal"] = /^(\d)+$/;
Ext.form.VTypes["phoneMask"] = /[\d]/;
Ext.form.VTypes["phoneText"] = 'Numero telefonico non valido.Digitare solo caratteri numerici';
Ext.form.VTypes["phone"] = function(v){
	return Ext.form.VTypes["phoneVal"].test(v);
};

Ext.BLANK_IMAGE_URL="/ext/resources/images/default/s.gif";

Ext.form.VTypes["numericVal"] = /^\s*-?((\d{1,3}(\.(\d){3})*)|\d*)(,\d{1,4})?\s?(\u20AC)?\s*$/;
Ext.form.VTypes["numericMask"] = /[\d]|[,]/;
Ext.form.VTypes["numericText"] = 'Digitare solo caratteri numerici';
Ext.form.VTypes["numeric"] = function(v){
	return Ext.form.VTypes["numericVal"].test(v);
};


Ext.form.VTypes["partitaivaVal"] = /^(\d){11}$/;
Ext.form.VTypes["partitaivaMask"] = /[\d]/;
Ext.form.VTypes["partitaivaText"] = 'Partita Iva non valida.';
Ext.form.VTypes["partitaiva"] = function(v){
	return Ext.form.VTypes["partitaivaVal"].test(v);
};


Ext.form.VTypes["codicefiscaleVal"] = /^[a-zA-Z]{6}\d\d[a-zA-Z]\d\d[a-zA-Z]\d\d\d[a-zA-Z]$/;
Ext.form.VTypes["codicefiscaleMask"] = /[a-zA-Z0-9]/;
Ext.form.VTypes["codicefiscaleText"] = 'Codice Fiscale non valida.';
Ext.form.VTypes["codicefiscale"] = function(v){
	return Ext.form.VTypes["codicefiscaleVal"].test(v);
};

Ext.form.VTypes["provVal"] = /^[a-zA-Z]{2}$/;
Ext.form.VTypes["provMask"] = /[a-zA-Z]/;
Ext.form.VTypes["provText"] = 'Provincia non valida.';
Ext.form.VTypes["prov"] = function(v){
	return Ext.form.VTypes["provVal"].test(v);
};


Ext.form.TextField.prototype.initValue = function()
{
    if(this.value !== undefined){
        this.setValue(this.value);
    }else if(this.el.dom.value.length > 0){
        this.setValue(this.el.dom.value);
    }
    if (!isNaN(this.maxLength) && 
    	(this.maxLength *1) > 0 && 
	(this.maxLength != Number.MAX_VALUE)) {
        this.el.dom.maxLength = this.maxLength *1;
    }
};  


Ext.util.Format.euroMoney = function(v){
      
			var f =parseFloat(v);
			if(f.toFixed)
				v=f.toFixed(4);
			else{
				  v = (Math.round((v-0)*100))/100;
			      v = (v == Math.floor(v)) ? v + ".00" : ((v*10 == Math.floor(v*10)) ? v + "0" : v);		
			}
            v = String(v);
            var ps = v.split('.');
            var whole = ps[0];

            var sub = ps[1] ? ','+ ps[1] : ',00';
            var r = /(\d+)(\d{3})/;
            while (r.test(whole)) {
                whole = whole.replace(r, '$1' + '.' + '$2');
            }
            v = whole + sub;
            if(v.charAt(0) == '-'){
                return '-€' + v.substr(1);
            }
            return "€" +  v;
};
		
		

		
		
Ext.namespace('Ext.ux.StyledHtmlEditor');

Ext.ux.StyledHtmlEditor = function(config){
this.styles = config.styles;
Ext.ux.StyledHtmlEditor.superclass.constructor.call(this, config);
};

Ext.extend(Ext.ux.StyledHtmlEditor, Ext.form.HtmlEditor, {
getDocMarkup : function(){
var markup = '<html><head><style type="text/css">body{border:0;margin:0;padding:3px;height:98%;curs or:text;}</style>';
if(this.styles) {

for (var i=0;i<this.styles.length;i++) {
markup = markup + '<link rel="stylesheet" type="text/css" href="'+this.styles[i]+'" />';
}
}
markup = markup + '</head><body></body></html>';
return markup;
}
});


function go(url){

	document.location=url;
}

function change_parent_title(title,id){
	if (id) {
		parent.Ext.getCmp("home_panel").activate(id);
	}
	
	parent.Ext.getCmp("home_panel").getActiveTab().setTitle(title)	;
}

function find_parent_tab(options){
					var hp = parent.Ext.getCmp("home_panel");
					var act = hp.getActiveTab();
					var p ;
					if (act.navigation_parent)
					{
						p=act.navigation_parent;
					}
					if(options.close){
						hp.remove(act);	
					}
					if (p) {
						hp.activate(p);
					}
					//provo il refresh -- sperimentale
					if (options.refresh)
					{
						
						if (p.getXType()=="iframepanel"){
								if (p.iframe.getWindow().refresher){
									p.iframe.getWindow().refresher();
								}
						}
					}
					
	}

function build_parent_tab(url,title){
		var d= new parent.Ext.ux.ManagedIframePanel({
								defaultSrc:url,
								loadMask:true,
								closable:true,
								title:title
							});
					//segno una nota per ricordarmi da dove vengo,.
					d.navigation_parent = parent.Ext.getCmp("home_panel").getActiveTab();
					parent.Ext.getCmp("home_panel").add(d);
					parent.Ext.getCmp("home_panel").activate(d);
	}
	
	
function getViewPort(percentage_to_remove){
	var v = Ext.getBody().getViewSize();
	v.width -= percentage_to_remove?v.width/100*percentage_to_remove:0;
	v.height -= percentage_to_remove?v.height/100*percentage_to_remove:0;
	return v;
}	
 
 
function remove_hiddens(form){
	Ext.each(form.findByType("hidden"),function(a){
		form.remove(a);
	});
} 