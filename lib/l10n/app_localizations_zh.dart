// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get chats => '聊天';

  @override
  String get contacts => '通讯录';

  @override
  String get me => '我';

  @override
  String get searchRoutes => '搜索你的航线...';

  @override
  String get noConversations => '暂无会话';

  @override
  String get loadFailed => '加载失败';

  @override
  String get connecting => '连接中...';

  @override
  String get connectionFailed => '连接失败';

  @override
  String get chat => '聊天';

  @override
  String get noMessages => '暂无消息';

  @override
  String get inputMessage => '输入消息...';

  @override
  String get crewList => '船员名单';

  @override
  String get searchTeammates => '寻找队友...';

  @override
  String get newCrew => '新的船员';

  @override
  String get groupChat => '群聊';

  @override
  String get tags => '标签';

  @override
  String get noFriends => '暂无好友';

  @override
  String get addCrew => '添加船员';

  @override
  String get username => '用户名';

  @override
  String get enterUsername => '输入对方的用户名';

  @override
  String get search => '搜索';

  @override
  String get userNotFound => '用户不存在';

  @override
  String get enterUsernameHint => '请输入用户名';

  @override
  String get friendRequestSent => '好友申请已发送';

  @override
  String get alreadySentRequest => '已经发送过好友申请，请等待对方处理';

  @override
  String get alreadyFriend => '对方已经是你的好友';

  @override
  String get cannotAddSelf => '不能添加自己为好友';

  @override
  String get requestMessage => '申请留言（可选）';

  @override
  String get requestMessageHint => '你好，加个好友吧';

  @override
  String get sendRequest => '发送申请';

  @override
  String get noFriendRequests => '暂无好友申请';

  @override
  String get addFriendProactively => '主动添加好友';

  @override
  String get retry => '重试';

  @override
  String get accept => '同意';

  @override
  String get reject => '拒绝';

  @override
  String get accepted => '已同意';

  @override
  String get rejected => '已拒绝';

  @override
  String get addFriend => '添加好友';

  @override
  String get account => '账号';

  @override
  String get enterPassword => '请输入密码';

  @override
  String get setAccount => '设置账号';

  @override
  String get setEmail => '设置邮箱';

  @override
  String get setPassword => '设置密码';

  @override
  String get captcha => '验证码';

  @override
  String get confirmRegister => '确 认 注 册';

  @override
  String get registerNew => '注册新账号';

  @override
  String get alreadyHaveAccount => '已有账号？去登录';

  @override
  String get loginToContinue => '登录以继续与好友保持联系';

  @override
  String get quickRegister => '快速创建你的SailChat账号';

  @override
  String get socialLogin => '社交账号快速登录';

  @override
  String get registerSuccess => '注册成功，请登录';

  @override
  String get requestFailed => '请求失败';

  @override
  String get networkError => '网络错误';

  @override
  String get captchaExpired => '验证码已过期';

  @override
  String get settings => '设置';

  @override
  String get appearance => '外观';

  @override
  String get language => '语言';

  @override
  String get logout => '退出登录';

  @override
  String get lightMode => '浅色模式';

  @override
  String get darkMode => '深色模式';

  @override
  String get followSystem => '跟随系统';

  @override
  String get selectAppearance => '选择外观';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get confirmLogout => '退出登录';

  @override
  String get confirmLogoutMessage => '确定要退出登录吗？';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get favorites => '收藏';

  @override
  String get album => '相册';

  @override
  String get cardPack => '卡包';

  @override
  String get data => '数据';

  @override
  String sailId(Object username) {
    return 'Sail号：$username';
  }

  @override
  String get loadFailedRetry => '加载失败';

  @override
  String get dataManagement => '数据管理';

  @override
  String get chatHistory => '聊天记录';

  @override
  String get clearChatData => '清除聊天数据';

  @override
  String get clearChatDataConfirm => '确定要清除所有聊天记录吗？此操作不可恢复。';

  @override
  String get clearChatDataHint => '清除后聊天记录将被删除，不可恢复';

  @override
  String get chatDataCleared => '聊天数据已清除';

  @override
  String get calculating => '计算中...';

  @override
  String get yesterday => '昨天';

  @override
  String get male => '男';

  @override
  String get female => '女';

  @override
  String get unknown => '未知';

  @override
  String accountLabel(Object username) {
    return '账号：$username';
  }

  @override
  String genderLabel(Object gender) {
    return '性别：$gender';
  }

  @override
  String userPrefix(Object id) {
    return '用户$id';
  }

  @override
  String get showBadge => 'showBadge';

  @override
  String get searchResults => '搜索结果';

  @override
  String get traditionalChinese => '繁体中文';

  @override
  String get friendApplyTitle => '好友申请';

  @override
  String get friendAcceptTitle => '好友通过';

  @override
  String get friendRejectTitle => '好友被拒';

  @override
  String get profile => '个人信息';

  @override
  String get save => '保存';

  @override
  String get saveSuccess => '保存成功';

  @override
  String get saveFailed => '保存失败';

  @override
  String get nickname => '昵称';

  @override
  String get avatar => '头像';

  @override
  String get region => '地区';

  @override
  String get gender => '性别';

  @override
  String get signature => '个性签名';

  @override
  String get avatarUrl => '头像链接';

  @override
  String get enterAvatarUrl => '请输入头像URL';

  @override
  String get selectGender => '选择性别';

  @override
  String get changeAvatar => '更换头像';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromAlbum => '从相册选择';

  @override
  String get avatarUploadSuccess => '头像上传成功';

  @override
  String get avatarUploadFailed => '头像上传失败';

  @override
  String get friendDetail => '好友详情';

  @override
  String get remark => '备注';

  @override
  String get goChat => '去聊天';

  @override
  String get sendImage => '发送图片';

  @override
  String get sendVideo => '发送视频';

  @override
  String get uploading => '上传中...';

  @override
  String get uploadFailed => '上传失败';

  @override
  String get sending => '发送中...';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw(): super('zh_TW');

  @override
  String get login => '登入';

  @override
  String get register => '註冊';

  @override
  String get chats => '聊天';

  @override
  String get contacts => '通訊錄';

  @override
  String get me => '我';

  @override
  String get searchRoutes => '搜尋你的航線...';

  @override
  String get noConversations => '暫無會話';

  @override
  String get loadFailed => '載入失敗';

  @override
  String get connecting => '連線中...';

  @override
  String get connectionFailed => '連線失敗';

  @override
  String get chat => '聊天';

  @override
  String get noMessages => '暫無訊息';

  @override
  String get inputMessage => '輸入訊息...';

  @override
  String get crewList => '船員名單';

  @override
  String get searchTeammates => '尋找隊友...';

  @override
  String get newCrew => '新的船員';

  @override
  String get groupChat => '群聊';

  @override
  String get tags => '標籤';

  @override
  String get noFriends => '暫無好友';

  @override
  String get addCrew => '添加船員';

  @override
  String get username => '使用者名稱';

  @override
  String get enterUsername => '輸入對方的使用者名稱';

  @override
  String get search => '搜尋';

  @override
  String get userNotFound => '使用者不存在';

  @override
  String get enterUsernameHint => '請輸入使用者名稱';

  @override
  String get friendRequestSent => '好友申請已發送';

  @override
  String get alreadySentRequest => '已經發送過好友申請，請等待對方處理';

  @override
  String get alreadyFriend => '對方已經是你的好友';

  @override
  String get cannotAddSelf => '不能添加自己為好友';

  @override
  String get requestMessage => '申請留言（可選）';

  @override
  String get requestMessageHint => '你好，加個好友吧';

  @override
  String get sendRequest => '發送申請';

  @override
  String get noFriendRequests => '暫無好友申請';

  @override
  String get addFriendProactively => '主動添加好友';

  @override
  String get retry => '重試';

  @override
  String get accept => '同意';

  @override
  String get reject => '拒絕';

  @override
  String get accepted => '已同意';

  @override
  String get rejected => '已拒絕';

  @override
  String get addFriend => '添加好友';

  @override
  String get account => '帳號';

  @override
  String get enterPassword => '請輸入密碼';

  @override
  String get setAccount => '設定帳號';

  @override
  String get setEmail => '設定信箱';

  @override
  String get setPassword => '設定密碼';

  @override
  String get captcha => '驗證碼';

  @override
  String get confirmRegister => '確 認 註 冊';

  @override
  String get registerNew => '註冊新帳號';

  @override
  String get alreadyHaveAccount => '已有帳號？去登入';

  @override
  String get loginToContinue => '登入以繼續與好友保持聯繫';

  @override
  String get quickRegister => '快速建立你的SailChat帳號';

  @override
  String get socialLogin => '社交帳號快速登入';

  @override
  String get registerSuccess => '註冊成功，請登入';

  @override
  String get requestFailed => '請求失敗';

  @override
  String get networkError => '網路錯誤';

  @override
  String get captchaExpired => '驗證碼已過期';

  @override
  String get settings => '設定';

  @override
  String get appearance => '外觀';

  @override
  String get language => '語言';

  @override
  String get logout => '登出';

  @override
  String get lightMode => '淺色模式';

  @override
  String get darkMode => '深色模式';

  @override
  String get followSystem => '跟隨系統';

  @override
  String get selectAppearance => '選擇外觀';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get confirmLogout => '登出';

  @override
  String get confirmLogoutMessage => '確定要登出嗎？';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確定';

  @override
  String get favorites => '收藏';

  @override
  String get album => '相簿';

  @override
  String get cardPack => '卡包';

  @override
  String get data => '資料';

  @override
  String sailId(Object username) {
    return 'Sail號：$username';
  }

  @override
  String get loadFailedRetry => '載入失敗';

  @override
  String get dataManagement => '資料管理';

  @override
  String get chatHistory => '聊天記錄';

  @override
  String get clearChatData => '清除聊天資料';

  @override
  String get clearChatDataConfirm => '確定要清除所有聊天記錄嗎？此操作無法復原。';

  @override
  String get clearChatDataHint => '清除後聊天記錄將被刪除，無法復原';

  @override
  String get chatDataCleared => '聊天資料已清除';

  @override
  String get calculating => '計算中...';

  @override
  String get yesterday => '昨天';

  @override
  String get male => '男';

  @override
  String get female => '女';

  @override
  String get unknown => '未知';

  @override
  String accountLabel(Object username) {
    return '帳號：$username';
  }

  @override
  String genderLabel(Object gender) {
    return '性別：$gender';
  }

  @override
  String userPrefix(Object id) {
    return '使用者$id';
  }

  @override
  String get showBadge => 'showBadge';

  @override
  String get searchResults => '搜尋結果';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get friendApplyTitle => '好友申請';

  @override
  String get friendAcceptTitle => '好友通過';

  @override
  String get friendRejectTitle => '好友被拒';

  @override
  String get profile => '個人資訊';

  @override
  String get save => '儲存';

  @override
  String get saveSuccess => '儲存成功';

  @override
  String get saveFailed => '儲存失敗';

  @override
  String get nickname => '暱稱';

  @override
  String get avatar => '頭像';

  @override
  String get region => '地區';

  @override
  String get gender => '性別';

  @override
  String get signature => '個性簽名';

  @override
  String get avatarUrl => '頭像連結';

  @override
  String get enterAvatarUrl => '請輸入頭像URL';

  @override
  String get selectGender => '選擇性別';

  @override
  String get changeAvatar => '更換頭像';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromAlbum => '從相簿選擇';

  @override
  String get avatarUploadSuccess => '頭像上傳成功';

  @override
  String get avatarUploadFailed => '頭像上傳失敗';

  @override
  String get friendDetail => '好友詳情';

  @override
  String get remark => '備註';

  @override
  String get goChat => '去聊天';

  @override
  String get sendImage => '發送圖片';

  @override
  String get sendVideo => '發送影片';

  @override
  String get uploading => '上傳中...';

  @override
  String get uploadFailed => '上傳失敗';

  @override
  String get sending => '發送中...';
}
