# User Agent iOS

User Agent is the internal name for the Ghostery iOS browser. A diferent name was chosen to highlight the new project, differentiate the project from the previous code bases, and to keep the option open to build multiple apps (e.g. Ghostery and Cliqz) out of the same codebase.

## Requirements

- Xcode 12
- [HomeBrew](https://brew.sh/)

## Building the Code

1. Clone the repository:
```shell
git clone git@github.com:ghostery/user-agent-ios.git
```
1. Run the bootstrap script to install dependencies
```shell
cd user-agent-ios
sh ./bootstrap.sh
```
1. Open `UserAgent.xcworkspace` in Xcode.

## Localization

Localization works as described in the [Apple Documentation](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LocalizingYourApp/LocalizingYourApp.html) or [this helpful tutorial](https://medium.com/swift-india/localize-your-apps-to-support-multiple-languages-ios-localization-ac7b612dbc58). Strings files are included in the project and can be exported to and imported from Xliff files if necessary for translation by external translation agencies.

Strings files live in the `Translations` directory,

To test localization, you can edit your currently active scheme, and in "Options", set the "Application Language". Don't commit this change please.

## Licensing

Code is licensed under the [Mozilla Public License 2.0](https://github.com/ghostery/user-agent-ios/blob/develop/LICENSE).

## Contributor guidelines

### General Guidelines

* Please note that this project is released with a [Contributor Code of Conduct](https://github.com/ghostery/user-agent-ios/blob/develop/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### Creating a pull request

* All pull requests must be associated with a specific Issue. If an issue doesn't exist please first create it.
* Please fill out the pull request template to your best ability.

### Swift style

* Swift code should generally follow the conventions listed at https://github.com/raywenderlich/swift-style-guide.
  * Exception: we use 4-space indentation instead of 2.
  * This is a loose standard. We do our best to follow this style

### Whitespace

* New code should not contain any trailing whitespace.
* We recommend enabling both the "Automatically trim trailing whitespace" and "Including whitespace-only lines" preferences in Xcode (under Text Editing).
* <code>git rebase --whitespace=fix</code> can also be used to remove whitespace from your commits before issuing a pull request.

### Commits

* Each commit should have a single clear purpose. If a commit contains multiple unrelated changes, those changes should be split into separate commits.
* If a commit requires another commit to build properly, those commits should be squashed.
