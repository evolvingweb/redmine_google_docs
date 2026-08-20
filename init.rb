require 'redmine'

# R7: no manual require — GoogleAppsMacros (lib/google_apps_macros.rb) autoloads
# when the macros below run (Zeitwerk). refs #108530.
Redmine::Plugin.register :redmine_google_docs do
  name "Google Docs Plugin"
  author 'Tavish Armstrong'
  description 'Embed Google Docs in your redmine pages.'
  version '7.0.0'
  requires_redmine version_or_higher: '7.0.0'

  Redmine::WikiFormatting::Macros.register do
    desc = "Redmine Google Spreadsheet Macro (gs)"
    macro :gs do |obj, args|
      out = GoogleAppsMacros::SpreadsheetMacros.googless_macro(obj, args).html_safe
    end

    desc = "Redmine Google Spreadsheet Macro (googless)"
    macro :googless do |obj, args|
      out = GoogleAppsMacros::SpreadsheetMacros.googless_macro(obj, args).html_safe
    end

    desc = "Redmine Google Spreadsheet Macro (googlespreadsheet)"
    macro :googlespreadsheet do |obj, args|
      out = GoogleAppsMacros::SpreadsheetMacros.googless_macro(obj, args).html_safe
    end

    desc = "Redmine Google Spreadsheet Macro (googlespread)"
    macro :googlespread do |obj, args|
      out = GoogleAppsMacros::SpreadsheetMacros.googless_macro(obj, args).html_safe
    end

    desc = "Redmine Google Spreadsheet Macro (gi)"
    macro :gi do |obj, args|
      GoogleAppsMacros::SpreadsheetMacros.get_issue(obj, args).html_safe
    end

    desc = "Redmine Google Spreadsheet Macro (googleissue)"
    macro :googleissue do |obj, args|
      GoogleAppsMacros::SpreadsheetMacros.get_issue(obj, args).html_safe
    end

    desc = "Redmine Google Document Macro (googledoc)"
    macro :googledoc do |obj, args|
      GoogleAppsMacros::DocumentMacros.get_doc(obj, args).html_safe
    end
  end
end
