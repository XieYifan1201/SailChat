// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get chats => 'Chats';

  @override
  String get contacts => 'Contacts';

  @override
  String get me => 'Me';

  @override
  String get searchRoutes => 'Search your routes...';

  @override
  String get noConversations => 'No conversations';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get chat => 'Chat';

  @override
  String get noMessages => 'No messages';

  @override
  String get inputMessage => 'Type a message...';

  @override
  String get crewList => 'Crew List';

  @override
  String get searchTeammates => 'Find teammates...';

  @override
  String get newCrew => 'New Crew';

  @override
  String get groupChat => 'Group Chat';

  @override
  String get tags => 'Tags';

  @override
  String get noFriends => 'No friends';

  @override
  String get addCrew => 'Add Crew';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get search => 'Search';

  @override
  String get userNotFound => 'User not found';

  @override
  String get enterUsernameHint => 'Please enter a username';

  @override
  String get friendRequestSent => 'Friend request sent';

  @override
  String get alreadySentRequest => 'Friend request already sent, please wait';

  @override
  String get alreadyFriend => 'Already your friend';

  @override
  String get cannotAddSelf => 'Cannot add yourself as a friend';

  @override
  String get requestMessage => 'Message (optional)';

  @override
  String get requestMessageHint => 'Hi, let\'s be friends!';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get noFriendRequests => 'No friend requests';

  @override
  String get addFriendProactively => 'Add a friend';

  @override
  String get retry => 'Retry';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get accepted => 'Accepted';

  @override
  String get rejected => 'Rejected';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get account => 'Account';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get setAccount => 'Set account';

  @override
  String get setEmail => 'Set email';

  @override
  String get setPassword => 'Set password';

  @override
  String get captcha => 'Captcha';

  @override
  String get confirmRegister => 'Register';

  @override
  String get registerNew => 'Create new account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get loginToContinue => 'Login to stay connected with friends';

  @override
  String get quickRegister => 'Create your SailChat account';

  @override
  String get socialLogin => 'Quick login with social accounts';

  @override
  String get registerSuccess => 'Registration successful, please login';

  @override
  String get requestFailed => 'Request failed';

  @override
  String get networkError => 'Network error';

  @override
  String get captchaExpired => 'Captcha expired';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Log Out';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get followSystem => 'Follow System';

  @override
  String get selectAppearance => 'Select Appearance';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get confirmLogout => 'Log Out';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get favorites => 'Favorites';

  @override
  String get album => 'Album';

  @override
  String get cardPack => 'Card Pack';

  @override
  String get data => 'Data';

  @override
  String sailId(Object username) {
    return 'Sail ID: $username';
  }

  @override
  String get loadFailedRetry => 'Load failed';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get chatHistory => 'Chat History';

  @override
  String get clearChatData => 'Clear Chat Data';

  @override
  String get clearChatDataConfirm => 'Are you sure you want to clear all chat history? This cannot be undone.';

  @override
  String get clearChatDataHint => 'Chat history will be deleted and cannot be recovered';

  @override
  String get chatDataCleared => 'Chat data cleared';

  @override
  String get calculating => 'Calculating...';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get unknown => 'Unknown';

  @override
  String accountLabel(Object username) {
    return 'Account: $username';
  }

  @override
  String genderLabel(Object gender) {
    return 'Gender: $gender';
  }

  @override
  String userPrefix(Object id) {
    return 'User $id';
  }

  @override
  String get showBadge => 'showBadge';

  @override
  String get searchResults => 'Search Results';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get friendApplyTitle => 'Friend Request';

  @override
  String get friendAcceptTitle => 'Friend Accepted';

  @override
  String get friendRejectTitle => 'Friend Rejected';

  @override
  String get profile => 'Profile';

  @override
  String get save => 'Save';

  @override
  String get saveSuccess => 'Saved';

  @override
  String get saveFailed => 'Save failed';

  @override
  String get nickname => 'Nickname';

  @override
  String get avatar => 'Avatar';

  @override
  String get region => 'Region';

  @override
  String get gender => 'Gender';

  @override
  String get signature => 'Signature';

  @override
  String get avatarUrl => 'Avatar URL';

  @override
  String get enterAvatarUrl => 'Enter avatar URL';

  @override
  String get selectGender => 'Select Gender';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromAlbum => 'Choose from Album';

  @override
  String get avatarUploadSuccess => 'Avatar uploaded';

  @override
  String get avatarUploadFailed => 'Avatar upload failed';

  @override
  String get friendDetail => 'Friend Detail';

  @override
  String get remark => 'Remark';

  @override
  String get goChat => 'Chat';

  @override
  String get sendImage => 'Send Image';

  @override
  String get sendVideo => 'Send Video';

  @override
  String get uploading => 'Uploading...';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get sending => 'Sending...';
}
