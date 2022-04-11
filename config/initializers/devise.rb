Devise.setup do |config|
	config.authentication_keys = [:usuario]
	config.navigational_formats = [:json]
	config.secret_key = 'ad106d808db07d328b40eeedaf9bc8a97ed666b9d4ab443d6c31171717fa1834608c51802bd2c1024c60e29c0a29ef2c735511dbf0c0b9f555d8bdeb2c337a8e'
end