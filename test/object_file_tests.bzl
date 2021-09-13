# Copyright 2020 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Tests for `object_file`."""

load(
    "@build_bazel_rules_swift//test/rules:action_output_test.bzl",
    "action_output_test",
    "make_action_output_test_rule",
)

object_file_embed_bitcode_test = make_action_output_test_rule(
    config_settings = {
        "//command_line_option:features": [
            "swift.bitcode_embedded",
        ],
    },
)

object_file_embed_bitcode_wmo_test = make_action_output_test_rule(
    config_settings = {
        "//command_line_option:swiftcopt": [
            "-whole-module-optimization",
        ],
        "//command_line_option:features": [
            "swift.bitcode_embedded",
        ],
    },
)

def object_file_test_suite(name = "object_file"):
    """Test suite for `swift_library` generating object files.

    Args:
        name: The name prefix for all the nested tests
    """

    action_output_test(
        name = "{}_without_bitcode".format(name),
        expected_output = [
            "test/fixtures/debug_settings/simple_objs/Empty.swift.o",
        ],
        not_expected_output = [
            "test/fixtures/debug_settings/simple_objs/Empty.swift.bc",
        ],
        mnemonic = "SwiftCompile",
        tags = [name],
        target_under_test = "@build_bazel_rules_swift//test/fixtures/debug_settings:simple",
    )

    object_file_embed_bitcode_test(
        name = "{}_embed_bitcode".format(name),
        expected_output = [
            "test/fixtures/debug_settings/simple_objs/Empty.swift.bc",
            "test/fixtures/debug_settings/simple_objs/Empty.swift.o",
        ],
        mnemonic = "SwiftCompile",
        tags = [name],
        target_under_test = "@build_bazel_rules_swift//test/fixtures/debug_settings:simple",
    )

    object_file_embed_bitcode_wmo_test(
        name = "{}_embed_bitcode_wmo".format(name),
        expected_output = [
            "test/fixtures/debug_settings/simple_objs/Empty.swift.bc",
            "test/fixtures/debug_settings/simple_objs/Empty.swift.o",
        ],
        mnemonic = "SwiftCompile",
        tags = [name],
        target_under_test = "@build_bazel_rules_swift//test/fixtures/debug_settings:simple",
    )

    native.test_suite(
        name = name,
        tags = [name],
    )
