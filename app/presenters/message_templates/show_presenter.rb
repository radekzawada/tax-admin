class MessageTemplates::ShowPresenter
  ActiveMessagePackage = Struct.new(:id, :name, :messages_count, :url)

  PACKAGE_URL_SUFFIX = "#gid=%<id>s"

  def initialize(template)
    @template = template
  end

  delegate :name, :template_name, :url, :permitted_emails, to: :@template

  def created_at
    @template.created_at.strftime("%Y-%m-%d %H:%M")
  end

  def active_messages_packages
    @active_messages_packages ||= @template.messages_packages.active.map do |package|
      url = @template.url + format(PACKAGE_URL_SUFFIX, id: package.external_sheet_id)
      ActiveMessagePackage.new(package.id, package.name, 1, url)
    end
  end

  def processed_messages_packages
    @processed_messages_packages ||= @template.messages_packages.processed
  end
end
