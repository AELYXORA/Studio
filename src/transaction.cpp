#include "aelyxora/transaction.hpp"
#include <limits>
#include <type_traits>
#include <utility>
namespace aelyxora {
TransactionResult apply(Project& project, const Transaction& transaction) {
    if(project.revision!=transaction.expected_revision)
        return std::unexpected(std::vector<Diagnostic>{{ErrorCode::StaleRevision,"revision","stale project revision"}});
    if(transaction.commands.empty())
        return std::unexpected(std::vector<Diagnostic>{{ErrorCode::MissingField,"commands","transaction has no commands"}});
    if(project.revision==std::numeric_limits<std::uint64_t>::max())
        return std::unexpected(std::vector<Diagnostic>{{ErrorCode::StaleRevision,"revision","revision overflow"}});
    Project candidate=project;
    for(const auto& command:transaction.commands) {
        auto errors=std::visit([&](const auto& cmd)->std::vector<Diagnostic>{
            using T=std::decay_t<decltype(cmd)>;
            if constexpr(std::is_same_v<T,SetProjectName>) {
                candidate.name=cmd.name;
                return {};
            } else {
                if(cmd.from==cmd.to)
                    return {{ErrorCode::InvalidId,"components","rename must change identity"}};
                bool found=false;
                for(auto& module:candidate.modules)
                    for(auto& component:module.components)
                        if(component.id==cmd.from) { component.id=cmd.to;found=true; }
                if(!found)
                    return {{ErrorCode::UnresolvedDependency,"components","source component not found"}};
                for(auto& module:candidate.modules)
                    for(auto& component:module.components)
                        for(auto& dep:component.dependencies)
                            if(dep==cmd.from) dep=cmd.to;
                return {};
            }
        },command);
        if(!errors.empty()) return std::unexpected(std::move(errors));
        errors=validate(candidate);
        if(!errors.empty()) return std::unexpected(std::move(errors));
    }
    ++candidate.revision;
    project=std::move(candidate);
    return project.revision;
}
}
