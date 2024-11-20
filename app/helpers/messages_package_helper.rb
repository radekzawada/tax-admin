module MessagesPackageHelper
  PACKAGE_URL_SUFFIX = "#gid=%<id>s"

  def external_url(template, package)
    template.url + format(PACKAGE_URL_SUFFIX, id: package.external_sheet_id)
  end
end
