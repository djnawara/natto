require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do
  describe "route generation" do

    it "should map { :controller => 'pages', :action => 'index' } to /pages" do
      route_for(:controller => "pages", :action => "index").should == "/pages"
    end
  
    it "should map { :controller => 'pages', :action => 'new' } to /pages/new" do
      route_for(:controller => "pages", :action => "new").should == "/pages/new"
    end
  
    it "should map { :controller => 'pages', :action => 'show', :id => 1 } to /pages/1" do
      route_for(:controller => "pages", :action => "show", :id => 1).should == "/pages/1"
    end
  
    it "should map { :controller => 'pages', :action => 'edit', :id => 1 } to /pages/1/edit" do
      route_for(:controller => "pages", :action => "edit", :id => 1).should == "/pages/1/edit"
    end
  
    it "should map { :controller => 'pages', :action => 'update', :id => 1} to /pages/1" do
      route_for(:controller => "pages", :action => "update", :id => 1).should == "/pages/1"
    end
  
    it "should map { :controller => 'pages', :action => 'destroy', :id => 1} to /pages/1" do
      route_for(:controller => "pages", :action => "destroy", :id => 1).should == "/pages/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'pages', action => 'index' } from GET /pages" do
      params_from(:get, "/pages").should == {:controller => "pages", :action => "index"}
    end
  
    it "should generate params { :controller => 'pages', action => 'new' } from GET /pages/new" do
      params_from(:get, "/pages/new").should == {:controller => "pages", :action => "new"}
    end
  
    it "should generate params { :controller => 'pages', action => 'create' } from POST /pages" do
      params_from(:post, "/pages").should == {:controller => "pages", :action => "create"}
    end
  
    it "should generate params { :controller => 'pages', action => 'show', id => '1' } from GET /pages/1" do
      params_from(:get, "/pages/1").should == {:controller => "pages", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'pages', action => 'edit', id => '1' } from GET /pages/1;edit" do
      params_from(:get, "/pages/1/edit").should == {:controller => "pages", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'pages', action => 'update', id => '1' } from PUT /pages/1" do
      params_from(:put, "/pages/1").should == {:controller => "pages", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'pages', action => 'destroy', id => '1' } from DELETE /pages/1" do
      params_from(:delete, "/pages/1").should == {:controller => "pages", :action => "destroy", :id => "1"}
    end
  end
end
