#pragma once
#include "aelyxora/model.hpp"
#include <expected>
#include <filesystem>
#include <optional>
#include <string>
#include <string_view>
namespace aelyxora {
using LoadResult=std::expected<Project,std::vector<Diagnostic>>;
using SaveResult=std::expected<void,std::vector<Diagnostic>>;
LoadResult parse_project(std::string_view json);
std::expected<std::string,std::vector<Diagnostic>> serialize_project(const Project&);
LoadResult load_project(const std::filesystem::path&);
SaveResult save_project(const std::filesystem::path&,const Project&,std::optional<std::uint64_t> expected_revision=std::nullopt);
}
