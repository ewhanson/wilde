xquery version "3.0";

import module namespace config="http://nines.ca/exist/wilde/config" at "modules/config.xqm";
import module namespace functx="http://www.functx.com";
import module namespace text="http://exist-db.org/xquery/text";
import module namespace debug="http://nines.ca/exist/wilde/debug" at "modules/debug.xql";

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace system="http://exist-db.org/xquery/system";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
    
else if ($exist:resource = 'debug' and request:get-server-name() = 'localhost') then
  debug:debug()
    
else if (ends-with($exist:resource, ".html")) then
  (: the html page is run through view.xql to expand templates :)
  <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
    <view>
        <forward url="{$exist:controller}/modules/view.xql"/>
    </view> {
      if(request:get-server-name() = 'localhost') then
        ()
      else
    		<error-handler>
    			<forward url="{$exist:controller}/error-page.html" method="get"/>
    			<forward url="{$exist:controller}/modules/view.xql"/>
    		</error-handler>    	
    }
  </dispatch>
    
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
    
else if(contains($exist:path, "/export/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/export.xql">
            <set-attribute name="function" value="{substring-after($exist:path, '/export/')}"/>
        </forward>
    </dispatch>

else if(contains($exist:path, "/api/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/api-public.xql">
            <set-attribute name="function" value="{substring-after($exist:path, '/api/')}"/>
        </forward>
    </dispatch>

else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
