#pragma once

#include <string>
#include <json/json.h>
#include <json/writer.h>
#include <ostream>

namespace cpd {

    inline std::string get_json(Json::Value whatever) {
        Json::StreamWriterBuilder builder;
        builder.settings_["indentation"] = "    ";
        std::string out = Json::writeString(builder, whatever);
        return out;
    };
}
