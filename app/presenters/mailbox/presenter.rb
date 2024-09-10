class Mailbox::Presenter
  def template_data_containers
    @template_data_containers ||= TemplateDataContainer.all
  end

  def disabled_templates
    template_data_containers.pluck(:template_name)
  end
end
