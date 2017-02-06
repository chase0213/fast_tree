$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fast_tree/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fast_tree"
  s.version     = FastTree::VERSION
  s.authors     = ["Chisato Hasegawa"]
  s.email       = ["chase0213@gmail.com"]
  s.homepage    = "https://github.com/chase0213/fast_tree"
  s.summary     = "Rails plugin for Fast Tree Structure",
  s.description = "fast_tree is an implementation of tree structure using nested sets model",
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "acts_as_tree"
end
