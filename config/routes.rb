ActionController::Routing::Routes.draw do |map|
  map.resources :companies

  map.resources :users

  map.resource :session

  map.resources :suppliers

  map.connect "/customer/projects",:controller =>"customers",:action=>"projects"
  map.resources :customers

  map.resources :documents

  map.connect "/reports/:action" ,:controller =>"reports"

  map.connect "/projects/categories/",:controller =>"projects",:action=>"categories"  
  map.connect "/projects/duplicate/:id",:controller =>"projects",:action=>"duplicate"  
  map.connect "/projects/list_item_data/:id",:controller =>"projects",:action=>"list_item_data"  
  
  map.connect "/budgetitem/",:controller =>"budgets",:action=>"budget_item_data"
  map.connect "/projectitem/:id",:controller =>"projects",:action=>"project_item_data"
  map.resources :budgets
  map.resources :projects
  map.connect "/orderitem/:id",:controller =>"orders",:action=>"order_by_item"
  map.connect "/orders/:action" ,:controller =>"orders"
  map.connect "/orders/:action/:id" ,:controller =>"orders"
  map.resources :orders

map.connect "/pricingitem/:id",:controller =>"pricings",:action=>"pricing_by_item"
map.connect "/pricing/:action" ,:controller =>"pricings"
map.connect "/pricing/:action/:id" ,:controller =>"pricings"
map.resources :pricings

map.connect "/invoiceitem/:id",:controller =>"invoices",:action=>"invoice_by_item"
map.connect "/invoices/:action" ,:controller =>"invoices"
map.connect "/invoices/:action/:id" ,:controller =>"invoices"
map.resources :invoices

map.connect "/proceeds/:action" ,:controller =>"proceeds"
map.connect "/proceeds/:action/:id" ,:controller =>"proceeds"

map.connect "/timesheet/:action" ,:controller =>"timesheet"
map.connect "/timesheet/:data" ,:controller =>"timesheet"
map.connect "/timesheet/:action/:data" ,:controller =>"timesheet"
map.resources :reportorders
map.resources :reportinvoices
map.resources :reportpricings
map.resources :reportprojects
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  
end
