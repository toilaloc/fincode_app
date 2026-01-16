# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

puts 'Seeding users...'
users = User.create!([
	{
		first_name: 'John', last_name: 'Doe', display_name: 'johndoe', email: 'johnwick@example.com', password: 'password', password_confirmation: 'password'
	},
	{
		first_name: 'Jane', last_name: 'Smith', display_name: 'janesmith', email: 'janewick@example.com', password: 'password', password_confirmation: 'password'
	}
])

puts 'Seeding categories...'
categories = Category.create!([
	{ name: 'Electronics 1', icon: 'fa-solid fa-tv' },
	{ name: 'Books 2', icon: 'fa-solid fa-book' },
	{ name: 'Clothing 3', icon: 'fa-solid fa-tshirt' }
])

puts 'Seeding products...'
Product.create!([
	{ name: "Smart TV 1", user: users[0], category: categories[0], price: 1000 },
	{ name: "Ruby Programming Book 2", user: users[0], category: categories[1], price: 2000 },
	{ name: "T-Shirt 3", user: users[1], category: categories[2], price: 3000 },
	{ name: "Laptop 4", user: users[1], category: categories[0], price: 4000 }
])
puts 'Seeding done.'
