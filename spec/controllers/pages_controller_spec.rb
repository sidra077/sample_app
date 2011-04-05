require 'spec_helper'

describe PagesController do
  render_views

  describe "GET 'home'" do
    it "should have the right title" do
      get 'home'
      response.should have_selector("title", :content => "Ruby on Rails | Home")
    end
  end

  describe "GET 'contact'" do
    it "should have the right title" do
      get 'contact'
      response.should have_selector("title", :content => "Ruby on Rails | Contact")
          end
  end

  describe "GET 'about'" do
    it "should have the right title" do
      get 'about'
      response.should have_selector("title", :content => "Ruby on Rails | About")
    end
  end

end
     