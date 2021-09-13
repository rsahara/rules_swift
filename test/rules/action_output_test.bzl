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

"""Rules for testing the outputs declared in the actions."""

load("@bazel_skylib//lib:collections.bzl", "collections")
load("@bazel_skylib//lib:unittest.bzl", "analysistest", "unittest")

def _action_output_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)

    # Find the desired action and verify that there is exactly one.
    actions = analysistest.target_actions(env)
    mnemonic = ctx.attr.mnemonic
    matching_actions = [
        action
        for action in actions
        if action.mnemonic == mnemonic
    ]
    if not matching_actions:
        actual_mnemonics = collections.uniq(
            [action.mnemonic for action in actions],
        )
        unittest.fail(
            env,
            ("Target '{}' registered no actions with the mnemonic '{}' " +
             "(it had {}).").format(
                str(target_under_test.label),
                mnemonic,
                actual_mnemonics,
            ),
        )
        return analysistest.end(env)
    if len(matching_actions) != 1:
        unittest.fail(
            env,
            ("Expected exactly one action with the mnemonic '{}', " +
             "but found {}.").format(
                mnemonic,
                len(matching_actions),
            ),
        )
        return analysistest.end(env)

    action = matching_actions[0]
    message_prefix = "In {} action for target '{}', ".format(
        mnemonic,
        str(target_under_test.label),
    )

    outputs = [file.short_path for file in action.outputs.to_list()]
    for expected in ctx.attr.expected_output:
        if expected not in outputs:
            unittest.fail(
                env,
                "{}expected outputs to contain '{}', but it did not: {}".format(
                    message_prefix,
                    expected,
                    outputs,
                ),
            )
    for not_expected in ctx.attr.not_expected_output:
        if not_expected in outputs:
            unittest.fail(
                env,
                "{}expected outputs to not contain '{}', but it did: {}".format(
                    message_prefix,
                    not_expected,
                    outputs,
                ),
            )
    
    return analysistest.end(env)

def make_action_output_test_rule(config_settings = {}):
    """Returns a new `action_output_test`-like rule with custom configs.

    Args:
        config_settings: A dictionary of configuration settings and their values
            that should be applied during tests.

    Returns:
        A rule returned by `analysistest.make` that has the
        `action_output_test` interface and the given config settings.
    """
    return analysistest.make(
        _action_output_test_impl,
        attrs = {
            "expected_output": attr.string_list(
                mandatory = False,
                doc = """\
A list of files expected to be in the outputs of this action.
""",
            ),
            "not_expected_output": attr.string_list(
                mandatory = False,
                doc = """\
A list of files expected to not be in the outputs of this action.
""",
            ),
            "mnemonic": attr.string(
                mandatory = True,
                doc = """\
The mnemonic of the action to be inspected on the target under test. It is
expected that there will be exactly one of these.
""",
            ),
        },
        config_settings = config_settings,
    )

# A default instantiation of the rule when no custom config settings are needed.
action_output_test = make_action_output_test_rule()
