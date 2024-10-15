from copy import deepcopy
from dataclasses import dataclass
from typing import List, Dict, Set

MY_INPUT="""F A M H C B J Z
addDependency  H C
addDependency  A B
addDependency  C A
addDependency  A B
addDependency  J A
addDependency  J M
addDependency  J H
build;"""

MY_INPUT2="""E X U G Z N D P
addDependency U X
addDependency D U
addDependency U G
addDependency X G
addDependency X D
addDependency P G
addDependency N Z
build;"""

@dataclass
class ModuleMeta:
    def __init__(self):
        self.requires: Set[str] = set()
        self.allows: Set[str] = set()

class AppBuilder:
    def __init__(self, _: int, module_names: List[str]):
        self.dependencies: Dict[str, ModuleMeta] = {}
        self.independent_modules: set[str] = set()

        for name in module_names:
            self.dependencies[name] = ModuleMeta()
            self.independent_modules.add(name)

    def add_dependency(self, prerequisite: str, module: str):
        if module in self.independent_modules:
            self.independent_modules.remove(module)
        self.dependencies[module].requires.add(prerequisite)
        self.dependencies[prerequisite].allows.add(module)

    def build_app(self):
        build_queue = list(deepcopy(self.independent_modules))
        built_modules: Set[str] = set()
        build_order = ""

        while build_queue:
            to_build = build_queue.pop(0)
            if to_build in built_modules:
                continue

            can_build = True
            for require in self.dependencies[to_build].requires:
                if require not in built_modules:
                    can_build = False
                    break

            if not can_build:
                continue

            built_modules.add(to_build)
            build_order += to_build
            build_queue.extend(list(self.dependencies[to_build].allows))

        print(build_order)


def main(my_input: str):
    splitted = my_input.split('\n')
    builder = AppBuilder(0, splitted[0].split())

    for line in splitted[1:-1]:
        _, prerequisite, module = line.split()
        builder.add_dependency(prerequisite, module)

    builder.build_app()


if __name__ == "__main__":
    main(MY_INPUT2)