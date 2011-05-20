class SecuredController < ApplicationController
  protect_from_forgery
  include Bcsec::Rails::SecuredController 
end