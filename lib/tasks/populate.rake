 namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'
    
     def random(model)
      ids = ActiveRecord::Base.connection.select_all("SELECT id FROM #{model.to_s.tableize}")
      model.find(ids[rand(ids.length)]["id"].to_i) unless ids.blank?
    end

    
    [Category, Project,Customer,Projectitem,Order,Invoice,Pricing,Orderitem,Pricingitem,Invoiceitem,Proceed,Document].each(&:delete_all)
        
    Customer.populate 50 do |customer|
      customer.ragionesociale = Faker::Company.name
      customer.partitaiva=Populator.value_in_range(000..1000).to_s
      customer.indirizzo = Faker::Address.street_address
      customer.comune = Faker::Address.city
      customer.cap = "00100"
      customer.note =Populator.sentences(2..10)
      customer.telefono = Faker::PhoneNumber.phone_number
      customer.fax= Faker::PhoneNumber.phone_number
      customer.email =   Faker::Internet.email
      customer.created_at =  1.month.ago..Time.now
      customer.updated_at = 1.month.ago..Time.now
      customer.coordinatebancarie= Populator.sentences(1..2)
      
      end
      Category.populate 10 do |category|
         category.name = Populator.words(1..3).titleize
         
      
      
    end
    index=0;
    Project.populate 30 do |project|
           # project.category_id=category.id
            project.title = Populator.words(1..5).titleize
            project.start =  1.month.ago..Time.now
            project.end =  project.start.advance(:months=>1)..project.start.advance(:months=>3)
            project.note = Populator.sentences(2..10)
            project.customer_id=1..50
            project.company_id = 953125641
            project.contact = Populator.sentences(2..10)
            project.year = 2008
            project.status_id=[1,2,3,4]
            project.user_id = random(User)
            index+=1
            project.code = "#{(index)}-#{project.year}"
             
            Projectitem.populate 10 do |pi|
              pi.project_id=project.id
              pi.quantity = 10..9999
              pi.cost = 1..1000
              pi.price = [0,pi.cost.to_f + (20.to_f/pi.cost.to_f * 100)]
              pi.created_at =  1.month.ago..Time.now
              pi.updated_at = 1.month.ago..Time.now
              pi.category_id = 1..10
              pi.description = Populator.sentences(2..5)
            end
            
#            Order.populate 1..2 do |order|
#                order.project_id = project.id
#                order.user_id = random(User)
#                order.created_at =  1.month.ago..Time.now
#                order.updated_at = 1.month.ago..Time.now
#                order.title= Populator.words(1..2).titleize
#                order.delivery  = Populator.words(1..2)
#                order.supplier_id = random(Supplier).id
#                order.paymentmethod_id = random(Paymentmethod).id
#                order.people = Populator.sentences(2..10)
#                order.notes = Populator.paragraphs(1)
#                order.received_invoice = [0,1]
#                order.amount_invoice = [1000,2000,3000]
#                order.expires_invoice=Time.now..Time.now.advance(:months=>3)
#                order.payed_invoice =  [0,1]
#                order.payed_invoice_date = order.payed_invoice==1 ? order.expires_invoice..order.expires_invoice.advance(:months=>2):nil
#                order.deleted = 1 unless order.received_invoice==1
#             end

#              Orderitem.populate 40 do |oi|
#                  tpi = random(Projectitem) 
#                  oi.order_id=random(Project).id
#                  oi.quantity = tpi.quantity
#                  oi.created_at = tpi.created_at
#                  oi.updated_at = tpi.updated_at
#                  oi.description = tpi.description
#                  oi.projectitem_id = tpi.id
#              end
             
            
            
           
            
       end
    
    
    
#    Person.populate 100 do |person|
#      person.name    = Faker::Name.name
#      person.company = Faker::Company.name
#      person.email   = Faker::Internet.email
#      person.phone   = Faker::PhoneNumber.phone_number
#      person.street  = Faker::Address.street_address
#      person.city    = Faker::Address.city
#      person.state   = Faker::Address.us_state_abbr
#      person.zip     = Faker::Address.zip_code
#    end
  end
end