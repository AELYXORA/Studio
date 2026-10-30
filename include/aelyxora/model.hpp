#pragma once
#include <cstdint>
#include <string>
#include <string_view>
#include <vector>
namespace aelyxora {
struct Target { std::string id, backend; };
struct Component {
    std::string id, type;
    std::vector<std::string> dependencies;
};
struct Module { std::string id; std::vector<Component> components; };
struct Project {
    std::string schema_version = "0.1-draft";
    std::string id, name;
    std::uint64_t revision = 0;
    std::vector<Target> targets;
    std::vector<Module> modules;
};
enum class ErrorCode {
    UnsupportedSchema, MissingField, InvalidId, DuplicateId,
    UnresolvedDependency, DependencyCycle, StaleRevision
};
struct Diagnostic { ErrorCode code; std::string path, message; };
std::vector<Diagnostic> validate(const Project& project);
struct ChangeResult {
    bool committed = false;
    std::vector<Diagnostic> diagnostics;
};
// Atomic in-memory change: mutate a candidate, publish only after validation.
// Persistence, source generation, migrations and JSON parsing are NOT implemented.
ChangeResult rename_component(Project& project, std::uint64_t expected_revision,
                              std::string_view component_id, std::string new_id);
} // namespace aelyxora
