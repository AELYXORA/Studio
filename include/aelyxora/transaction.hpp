#pragma once
#include "aelyxora/model.hpp"
#include <expected>
#include <string>
#include <variant>
#include <vector>
namespace aelyxora {
struct RenameComponent { std::string from, to; };
struct SetProjectName { std::string name; };
using Command = std::variant<RenameComponent, SetProjectName>;
struct Transaction {
    std::uint64_t expected_revision;
    std::vector<Command> commands;
};
using TransactionResult = std::expected<std::uint64_t, std::vector<Diagnostic>>;
// Atomic in-memory operation, committed only if all commands are valid.
TransactionResult apply(Project& project, const Transaction& transaction);
}
