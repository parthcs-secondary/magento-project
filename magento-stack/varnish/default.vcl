vcl 4.1;

import std;

backend default {
    .host = "nginx";
    .port = "8080";
    .first_byte_timeout = 600s;
    .between_bytes_timeout = 600s;
}

acl purge {
    "localhost";
    "127.0.0.1";
    "::1";
    "nginx"; # Allow internal network to purge
}

sub vcl_recv {
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return (synth(405, "Method not allowed"));
        }
        if (!req.http.X-Magento-Tags-Pattern) {
            return (synth(400, "X-Magento-Tags-Pattern header required"));
        }
        ban("obj.http.X-Magento-Tags ~ " + req.http.X-Magento-Tags-Pattern);
        return (synth(200, "Purged"));
    }

    if (req.method != "GET" && req.method != "HEAD" && req.method != "PUT" && req.method != "POST" && req.method != "TRACE" && req.method != "OPTIONS" && req.method != "DELETE") {
        return (pipe);
    }

    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    # Bypass cache for specific admin/checkout routes
    if (req.url ~ "/(admin|checkout|rest|graphql)") {
        return (pass);
    }

    return (hash);
}

sub vcl_backend_response {
    if (beresp.http.X-Magento-Debug) {
        set beresp.http.X-Magento-Cache-Control = beresp.http.Cache-Control;
    }
    if (beresp.http.X-Magento-Tags) {
        set beresp.http.Cache-Control = "public, max-age=86400";
    }
    return (deliver);
}

sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Magento-Cache-Debug = "HIT";
    } else {
        set resp.http.X-Magento-Cache-Debug = "MISS";
    }
}
