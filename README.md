# Little Explorer - Educational App

A Flutter application designed to provide educational content for children aged 4-6 years.

## Features

- Age-specific educational content
- Video learning materials
- Interactive games generated with AI
- Quizzes for knowledge assessment
- User-friendly content management system

## Getting Started

1. Clone the repository
2. Set up environment variables:
   - Copy `.env.example` to `.env`
   - Replace `your_api_key_here` with your actual Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Content Management

The app includes a content management system that allows administrators to:

1. Create subjects that are shared across all age groups (4-6 years)
2. Add age-specific modules to each subject
3. Upload video content or link YouTube videos
4. Generate interactive games using AI
5. Create quizzes to test knowledge
6. Preview all content before publishing

## Development

This project uses:

- Flutter for the frontend
- Firebase for backend services
- Gemini Pro AI for generating educational content
- Environment variables for secure configuration

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
