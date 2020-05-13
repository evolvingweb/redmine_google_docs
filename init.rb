require 'redmine'

require File.dirname(__FILE__) + '/lib/google_apps_macros.rb'

Redmine::Plugin.register :redmine_google_docs do
  name "Google Docs Plugin"
  author 'Tavish Armstrong'
  description 'Embed Google Docs in your redmine pages.'
  version '0.0.2'

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
