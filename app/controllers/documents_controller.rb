class DocumentsController < ApplicationController
  self.allow_forgery_protection = false
  before_filter :find_document, :only => [ :show, :edit, :update, :destroy ]
  layout "standard"
  upload_status_for  :create,  {:status => :custom_status}
  include AuthenticatedSystem
  
  # GET /documents
  # GET /documents.ext_json
  def index
     d=find_documents 
      @project = Project.find(params[:project_id])
    respond_to do |format|
      format.html     # index.html.erb (no data required)
    
      format.ext_json { render :json => d.to_ext_json(:class => :document, :count => @count,:methods=>:doc_mine,:include=>{:user=>{:only=>"login"}})}
    end
  end

   

  # GET /documents/1
  def show
#    redirect_to "/#{@document.doc_options[:base_url]}/#{@document.doc_relative_path}"
    send_file(@document.doc,:filename=>File.basename(@document.doc),:type=> "application/vnd.oasis.opendocument.text", :disposition => 'inline')
  end
 
    def upload_status
         # ... Override this action to return content to be replaced in
         # the status container
          render :inline => "In corso", :layout => false
     end

  # POST /documents
  def create
    @document = Document.new(params[:document])
    @document.user_id = current_user.id
    @document.project = Project.find(params[:project_id])
    @document.doctype ="allegato";
     if @document.save
        #flash[:notice] = 'Project was successfully created.'
        #finish_upload_status("function() { alert('File Inviato.');parent.Ext.getCmp('grid-docs').store.reload(); }")
#        render :inline => "<script>alert('File Inviato.');parent.Ext.getCmp('grid-docs').store.reload();</script>", :layout => false
#        render :text => "Percent complete: " + session[:uploads][request[:upload_id]].completed_percent
        render :inline =>{:success => true}.to_json
      else
        render :inline => {:success => false}.to_json
#        render :inline => "<script>alert('No')</script>", :layout => false
        
      end
    
  end
 
  # DELETE /documents/1
  def destroy
    @document.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_document
      @document= Document.find(params[:id]) 
    end
 
    def find_documents
      pagination_state = update_pagination_state_with_params!(:document)
#      params[:project_id]
      eopts = options_from_pagination_state(pagination_state).merge(options_from_search(:document))
      condition = {:conditions => "project_id="+params[:project_id]} if params[:project_id]
      mopts  = eopts.merge(condition)
      @count = Document.count(:all,options_from_search(:document).merge(condition))
      @documents = Document.find(:all, mopts )
  end
 

end
