class Mailbox::Presenter
  ContainerData = Struct.new(:name, :template, :url)

  def message_templates
    @message_templates ||= records.map do |container|
      ContainerData.new(
        container.name,
        I18n.t("admin.mailbox.index.templates.#{container.template_name}"),
        container.url
      )
    end
  end

  def disabled_templates
    records.pluck(:template_name)
  end

  def default_sheet_name
    "#{I18n.t("date.months.names.#{Date::MONTHNAMES[Time.current.month].downcase}")} #{Time.current.year}"
  end

  private

  def records
    @records ||= MessageTemplate.all
  end
end
