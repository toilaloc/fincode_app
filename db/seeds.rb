# frozen_string_literal: true
# Auto-generated seeds from current database state

puts 'Cleaning up database...'
Refund.delete_all
Payment.delete_all
Order.delete_all
Product.delete_all
Category.delete_all
User.delete_all

puts 'Seeding Users...'
User.create!(first_name: 'Test', last_name: 'Customer', display_name: 'Test Customer', email: 'test@example.com', id: 1, password: 'password', password_confirmation: 'password')
User.create!(first_name: 'John', last_name: 'Doe', display_name: 'johndoe', email: 'john@example.com', id: 2, password: 'password', password_confirmation: 'password')
User.create!(first_name: 'John', last_name: 'Doe', display_name: 'johndoe', email: 'johnwick@example.com', id: 6, password: 'password', password_confirmation: 'password')
User.create!(first_name: 'Jane', last_name: 'Smith', display_name: 'janesmith', email: 'janewick@example.com', id: 7, password: 'password', password_confirmation: 'password')

puts 'Seeding Categories...'
Category.create!(name: 'Electronics', icon: 'fa-solid fa-tv', id: 1)
Category.create!(name: 'Books', icon: 'fa-solid fa-book', id: 2)
Category.create!(name: 'Clothing', icon: 'fa-solid fa-tshirt', id: 3)
Category.create!(name: 'Electronics 1', icon: 'fa-solid fa-tv', id: 4)
Category.create!(name: 'Books 2', icon: 'fa-solid fa-book', id: 5)
Category.create!(name: 'Clothing 3', icon: 'fa-solid fa-tshirt', id: 6)

puts 'Seeding Products...'
Product.create!(name: 'Smart TV 1', price: 1000.0, user_id: 2, category_id: 1, id: 1)
Product.create!(name: 'Ruby Programming Book 2', price: 2000.0, user_id: 2, category_id: 1, id: 2)
Product.create!(name: 'T-Shirt 3', price: 3000.0, user_id: 2, category_id: 2, id: 3)
Product.create!(name: 'Laptop 4', price: 4000.0, user_id: 2, category_id: 2, id: 4)

puts 'Seeding done.'
