class ApiConfig {
  // 开发环境API地址（模拟器使用）
  static const String devBaseUrl = 'http://10.0.2.2:8080/api/v1';

  // 局域网测试地址（手机测试用 - 请根据 `ipconfig` 修改为宿主机IP）
  static const String lanBaseUrl = 'http://192.168.1.3:8080/api/v1';

  // 生产环境API地址（部署后修改）
  static const String prodBaseUrl = 'https://your-api-domain.com/api/v1';

  // 当前环境（开发/生产）
  static const bool isProduction = false;

  // 是否使用局域网地址（手机测试时改为 true）
  // 当前已为手机测试配置为 true
  static const bool useLAN = true;

  // 获取当前API地址
  static String get baseUrl => isProduction
      ? prodBaseUrl
      : (useLAN ? lanBaseUrl : devBaseUrl);

  // API端点
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  
  // 手机号登录
  static const String phoneSendCode = '/auth/phone/send-code';
  static const String phoneLogin = '/auth/phone/login';
  
  // 密码重置
  static const String passwordResetRequest = '/auth/password/reset-request';
  static const String passwordResetConfirm = '/auth/password/reset-confirm';

  static const String diaries = '/diaries';
  static String diaryById(int id) => '/diaries/$id';

  static const String challenges = '/challenges';
  static String challengeById(int id) => '/challenges/$id';
  static String challengeAttempts(int id) => '/challenges/$id/attempts';

  static const String tags = '/tags';
  static String tagById(int id) => '/tags/$id';
  static const String tagStats = '/tags/stats/usage';

  // 统计相关
  static const String statsOverview = '/stats/overview';
  static const String statsEmotionTrend = '/stats/emotion-trend';
  static const String statsIntensityDistribution = '/stats/emotion-intensity-distribution';
  static const String statsChallengeCompletion = '/stats/challenge-completion';

  // 提醒相关
  static const String reminders = '/reminders';
  static String reminderById(int id) => '/reminders/$id';

  // 导出相关
  static const String exportDiariesJson = '/export/diaries/json';
  static const String exportDiariesCsv = '/export/diaries/csv';
  static const String exportReportWeekly = '/export/report/weekly';
  static const String exportReportMonthly = '/export/report/monthly';

  // 超时设置
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
