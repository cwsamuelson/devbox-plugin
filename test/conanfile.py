from conan import ConanFile
from conan.tools.cmake import cmake_layout, CMake, CMakeDeps, CMakeToolchain
from conan.tools.files import copy
from conan.tools.scm import Git, Version
from conan.tools.env import Environment
from conan.errors import ConanInvalidConfiguration


class plugin_test(ConanFile):
    name = 'plugin_package_test'
    package_type = 'application'
    version = '1.0.0'
    license = 'GPL-3.0-or-later'
    author = 'Chris Samuelson (chris.sam55@gmail.com)'
    topics = ('utility', 'testing', 'reference')

    settings = 'os', 'compiler', 'build_type', 'arch'

    requires = [
    ]

    test_requires = [
    ]

    tool_requires = [
    ]

    options = {
    }

    default_options = {
    }

    def export_sources(self):
        git = Git(self)
        files = git.included_files()
        for file in files:
            copy(self, file, self.recipe_folder, self.export_sources_folder)

    def config_options(self):
        pass

    def configure(self):
        pass

    def requirements(self):
        pass

    def package_id(self):
        pass

    def validate(self):
        pass

    def generate(self):
        tool_chain = CMakeToolchain(self)
        tool_chain.generate()

        deps = CMakeDeps(self)
        deps.generate()

    def _configure_cmake(self):
        cmake = CMake(self)
        return cmake

    def build(self):
        cmake = self._configure_cmake()

        cmake.configure()

        cmake.build()

    def layout(self):
        cmake_layout(self)

    def package(self):
        cmake = self._configure_cmake()
        cmake.install()

