module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true,
    jest: true
  },
  extends: [
    'eslint:recommended'
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  rules: {
    // 允许中文变量名
    'no-irregular-whitespace': ['error', { 'skipStrings': true }],
    // 其他规则根据需要调整
    'no-unused-vars': 'warn',
    'no-console': 'off'
  }
};