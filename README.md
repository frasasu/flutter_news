# 📱 Flutter News

A mobile news application built with **Flutter** that connects to the [`api-news`](https://github.com/frasasu/api-news) REST API.

## 🚀 About

**Flutter News** is the mobile frontend for a full-stack news blog platform. It provides a native mobile experience for browsing articles, user authentication, article management, and comments.

The application consumes the RESTful API provided by [`api-news`](https://github.com/frasasu/api-news).

## 🔗 Backend API

This app works with the [`api-news`](https://github.com/frasasu/api-news) REST API.

| Feature | Endpoint | Method |
|---------|----------|--------|
| Register | `/api/auth/register` | POST |
| Login | `/api/auth/login` | POST |
| List Articles | `/api/articles` | GET |
| Article Details | `/api/articles/:id` | GET |
| Create Article | `/api/articles` | POST (Auth) |
| Comments | `/api/articles/:id/comments` | GET/POST |

For complete API documentation, visit the [`api-news` repository](https://github.com/frasasu/api-news).

## 🚦 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.x
- An emulator or physical device (iOS/Android)
- The [`api-news`](https://github.com/frasasu/api-news) backend running

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/frasasu/flutter_news.git
cd flutter_news

# 2. Install dependencies
flutter pub get

# 3. Run the application
flutter run
```

### Configuration

Configure the API base URL by creating a `.env` file:

```
API_BASE_URL=http://localhost:3000/api
```

## 👤 Author

**François** — [@frasasu](https://github.com/frasasu)  
Institut de Statistique Appliquée, Université du Burundi

## 📄 License

Educational and experimental purposes only.

---

## 🔗 Links

- [Backend API](https://github.com/frasasu/api-news)
- [Flutter Documentation](https://docs.flutter.dev/)