class Mailbox::Presenter
  ContainerData = Struct.new(:name, :template)

  def template_data_containers
    @template_data_containers ||= models.map do |container|
      ContainerData.new(
        container.name,
        I18n.t("admin.mailbox.index.templates.#{container.template_name}")
      )
    end
  end

  def disabled_templates
    models.pluck(:template_name)
  end

  private

  def models
    @models ||= TemplateDataContainer.all
  end
end
