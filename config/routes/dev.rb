scope "docs", controller: "docs", as: "docs" do
  get "/", action: :architecture, as: :root
  get "architecture"
  get "data_model"
  get "import_pipeline"
  get "design_system"
end
