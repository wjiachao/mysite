ActiveAdmin.register Post do
  permit_params :title, :content, :id, :style, :publish_date
  form do |f|
    inputs '内容' do
      input :title
      input :publish_date, label: "Publish Post At"
      li "Created at #{f.object.created_at}" unless f.object.new_record?
      if params[:style] == "markdown"
        input :content
      else
        input :content, :as => :kindeditor
      end
     
    end
    panel '详情' do
      "创建博客支持编辑文本器"
    end
    actions
  end


  index do
    column :title
    column :content
    column :publish_date
    actions
  end


end
