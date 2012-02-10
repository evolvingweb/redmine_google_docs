require 'redmine'
require 'digest/md5'
require 'yaml'
include ActionView::Helpers::JavaScriptHelper

module GoogleAppsMacros
  unloadable
class SpreadsheetMacros
  def self.googless_macro(googless_wiki_content, args, nohead=false)
    raise  "The correct usage is {{ googless(key,query) }}" unless args.length >= 1

    # redmine seemingly html-escapes all the wiki arguments, so we un-escape them
    key = escape_javascript(CGI.unescape(args[0]))

    sheet = "0"
    if args.length > 1
      # check to see if the second argument is a sheet. Otherwise, continue
      # assuming it's part of the query. @badidea
      begin
        possibly_sheet = args[1].to_s
        sheet = Integer(possibly_sheet.strip()).to_s
        querystart = 2
      rescue ArgumentError
        querystart = 1
        sheet = "0"
      rescue
        raise "Invalid sheet code"
      end

      # Queries can have commas in them, which the macro thinks are extra macro arguments.
      # We know they're just commas in the query, so join them.
      unescaped_query = args[querystart..-1].join(",").to_s.sub('"', '\"').strip()
      query = clean_key(unescaped_query)
    end

    render_spreadsheet(key, query, sheet)
  end

  def self.render_spreadsheet(key, query, sheet="0", nohead=false)

    if sheet.nil?
      raise "Sheet is nil"
    end
    sheet = sheet.strip()

    if nohead != "true"
      nohead = "false";
    end

    # get a random string to add to the element IDs so multiple spreadsheets don't conflict.
    dom_id = Digest::MD5.hexdigest(rand().to_s)
    
    out = <<"EOF"
<div>
  <style type="text/css">
  /* this is used to override the th and td className */
  /* see cssClassNames property in the invokation of table.draw() */
    .small-font {
      font-size:80%;
    }
    .googlespreadsheet {
      margin-right: 50px;
    }
  </style>
  <script type="text/javascript" src="https://www.google.com/jsapi"></script> 
  <script type="text/javascript"> 
  (function () {
    var prot, options, tableId, fakeSql, key, baseUrl;

    prot = (("https:" == document.location.protocol) ? "https://" : "http://");
    // Formatting options
    options = {
      showRowNumber: true,
      cssClassNames: {
        tableCell: 'small-font',
        headerCell: 'small-font'
      }
    };
  	// We want this to be unique for each embedded sheet. Otherwise only one sheet can display per page.
    tableId = 'table-' + "#{dom_id}";
    fakeSql = '#{query}';
    key = '#{key}';

    // Spreadsheets.google.com went bad, why should this be stable?
    baseUrl = 'docs.google.com/spreadsheet';

    google.load('visualization', '1.s');
    
    function drawVisualization() {
      google.visualization.drawChart({
        "containerId": tableId,
        "dataSourceUrl": prot + baseUrl + '/tq?gid=#{sheet}&key=' + key,
        "query": fakeSql,
        "refreshInterval": 5,
        "chartType": "Table",
        "options": options
      });
    }

   google.setOnLoadCallback(drawVisualization);

    var addLink = function () {
      var link = document.createElement('a');
      link.innerText = "Go to entire spreadsheet.";
      link.href = prot + baseUrl + '/ccc?key=' + key + '#' + 'gid=#{sheet}';

      var location = document.getElementById(tableId);
      location.parentNode.appendChild(link);
      };

    var oldLoad = window.onload;
    window.onload = function () {
    if (typeof(oldLoad) === "function") {
      oldLoad();
      }
      addLink();
      };

  }());
  </script>
</div>
<div class='googlespreadsheet' id='table-#{dom_id}'>
Loading Google Spreadsheet...
</div>
EOF
  end

  # a function for {{googleissue()}}
  def self.get_issue(obj, args)
    # usage: {{googleissue(adfSDFiuhDSF98SDFhiushdafbhIDFXF0dsf)}}
    # gives the row of the google spreadsheet containing the issue number in the second column
    goodargs = []
    key = clean_key(args[0])
    if args.length > 1
      sheet = clean_key(args[1])
    else
      sheet = "0"
    end

    if not obj.respond_to? :journalized_id or not obj.respond_to? :journalized_type
      if obj.is_a? Issue
        # we're in the "Description" part of the Issue page
        id = obj.id
      end
    else
      # we're in the comment thread of an Issue page
      id = obj.journalized_id
    end
    if id
      col = "B" #assuming second column
      issue_id = id
      issue_id_with_hash = "##{issue_id}"
      query = "SELECT * WHERE #{col}='#{issue_id}' OR #{col}=#{issue_id} OR #{col}='#{issue_id_with_hash}'"

      clean_query = clean_key(query)

      out = render_spreadsheet(key, clean_query, sheet, "true")
    else
      raise "You need to be on an issue page to use the <strong>googleissue</strong> macro."
    end
  end

  def self.clean_key(key)
    escape_javascript(CGI.unescape(key))
  end
end

class DocumentMacros
  def self.get_doc(obj, args)
    doc_key = args[0]
    action = false
    domain = false
    if args.length == 2
      case args[1].strip
        when "edit"
          action = "edit"
        when "view"
          action = "view"
        else /^[\w]+(\.+[\w-])+/
          domain = args[1].strip
      end
    end
    if args.length == 3
      domain = args[1].strip if /^[\w]+(\.+[\w-])+/.match(args[1].strip)
      action = "edit" if args[2].strip == "edit"
      action = "view" if args[2].strip == "view"
    end
    if /^[\w-]+$/.match(doc_key)
      if domain
        url = "https://docs.google.com/a/#{domain}/document/"
      else
        url = "https://docs.google.com/document/"
      end
      if action
        url += "d/#{doc_key}/#{action}"
      else
        url += "pub?id=#{doc_key}"
      end
      out = "<iframe src='#{url}' width='800' height='400'></iframe>"
    else
      raise "The Google document key must be alphanumeric."
    end
  end
end
end
