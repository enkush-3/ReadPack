'use strict';

/**
 * MongoDB Mongoose Schema Definition & Seed Catalog for the Central Books Collection (`books`).
 */
function registerMongooseCentralBookModel(mongoose) {
  if (mongoose.models && mongoose.models.CentralBook) {
    return mongoose.models.CentralBook;
  }

  const ChapterSchema = new mongoose.Schema(
    {
      id: { type: String, required: true },
      title: { type: String, required: true },
      estimatedMinutes: { type: Number, default: 10 },
      content: { type: String, required: true },
    },
    { _id: false }
  );

  const ReviewSchema = new mongoose.Schema(
    {
      id: { type: String, required: true },
      userName: { type: String, required: true },
      rating: { type: Number, default: 5.0 },
      comment: { type: String, required: true },
      createdAt: { type: String, default: () => new Date().toISOString() },
      helpfulCount: { type: Number, default: 0 },
    },
    { _id: false }
  );

  const CentralBookSchema = new mongoose.Schema(
    {
      id: { type: String, required: true, unique: true, index: true },
      externalSource: { type: String, default: 'central_seed' },
      externalId: { type: String, index: true },
      isbn13: { type: String, index: true },
      title: { type: String, required: true },
      normalizedTitle: { type: String, required: true, index: true },
      author: { type: String, required: true },
      normalizedAuthor: { type: String, required: true, index: true },
      description: { type: String, default: '' },
      rating: { type: Number, default: 4.6 },
      reviewsCount: { type: Number, default: 120 },
      category: { type: String, default: 'book.categories.all' },
      pages: { type: Number, default: 240 },
      readTimeMinutes: { type: Number, default: 200 },
      image: {
        type: String,
        default: 'assets/public/books/atomic_habits.png',
      },
      colorHex: { type: Number, default: 0xFF182350 },
      hasAudio: { type: Boolean, default: true },
      audioDurationMinutes: { type: Number, default: 200 },
      keyTakeaways: { type: [String], default: [] },
      tags: { type: [String], default: [] },
      chapters: { type: [ChapterSchema], default: [] },
      reviews: { type: [ReviewSchema], default: [] },
    },
    { timestamps: true }
  );

  return mongoose.model('CentralBook', CentralBookSchema, 'books');
}

function getInitialCentralBooks() {
  return [
    {
      id: '1',
      externalSource: 'central_seed',
      externalId: 'seed_atomic_habits',
      isbn13: '9780735211292',
      title: 'Atomic Habits',
      normalizedTitle: 'atomic habits',
      author: 'James Clear',
      normalizedAuthor: 'james clear',
      description:
          'Жижиг дадлуудаар дамжуулан амьдралдаа асар том өөрчлөлтийг авчрах шинжлэх ухааны батлагдсан аргачлал.',
      rating: 4.9,
      reviewsCount: 3420,
      category: 'book.categories.business',
      pages: 320,
      readTimeMinutes: 280,
      image: 'assets/public/books/atomic_habits.png',
      colorHex: 0xFF1E3A8A,
      hasAudio: true,
      audioDurationMinutes: 280,
      keyTakeaways: [
        'Өдөр бүр 1%-иар сайжрахад жилийн эцэст 37 дахин илүү үр дүнд хүрнэ.',
        'Зорилгод бус системд төвлөрөх нь урт хугацааны амжилтын үндэс.',
        'Дадлыг бий болгох 4 хууль: Ил тод болго, Сэтгэл татам болго, Хялбар болго, Сэтгэл ханамжтай болго.',
      ],
      tags: ['Habits', 'Productivity', 'Business'],
      chapters: [
        {
          id: '1_c1',
          title: '1-р бүлэг: Энгийн дадлын гайхамшигт хүч',
          estimatedMinutes: 12,
          content:
              'Амжилт бол амьдралд нэг удаа тохиох аварга өөрчлөлтийн үр дүн биш, харин өдөр тутмын жижиг дадлуудын нийлбэр юм. Та өдөр бүр ердөө 1 хувиар сайжирч чадвал жилийн эцэст анх эхэлснээсээ 37 дахин илүү болсон байх болно.',
        },
        {
          id: '1_c2',
          title: '2-р бүлэг: Таны дадал хэн болохыг тань хэрхэн тодорхойлдог вэ',
          estimatedMinutes: 15,
          content:
              'Өөрчлөлтийн гурван түвшин байдаг: үр дүн, үйл явц, болон мөн чанар (identity). Хамгийн бат бөх дадал бол өөрийнхөө хэн болохыг хүсэж буй мөн чанар дээр суурилсан дадал юм.',
        },
      ],
      reviews: [],
    },
    {
      id: '2',
      externalSource: 'central_seed',
      externalId: 'seed_thinking_fast_and_slow',
      isbn13: '9780374533557',
      title: 'Thinking, Fast and Slow',
      normalizedTitle: 'thinking fast and slow',
      author: 'Daniel Kahneman',
      normalizedAuthor: 'daniel kahneman',
      description:
          'Нобелийн шагналт сэтгэл судлаач Даниел Канеманы хүний оюун санааны хоёр системийн тухай суурь бүтээл.',
      rating: 4.8,
      reviewsCount: 2150,
      category: 'book.categories.science',
      pages: 499,
      readTimeMinutes: 420,
      image: 'assets/public/books/thinking_fast_and_slow.png',
      colorHex: 0xFF0F766E,
      hasAudio: true,
      audioDurationMinutes: 420,
      keyTakeaways: [
        'Систем 1 нь хурдан, зөн совингийн бөгөөд сэтгэл хөдлөлд автамтгай.',
        'Систем 2 нь удаан, логик тунгаан бодох чадвартай.',
      ],
      tags: ['Psychology', 'Science', 'DecisionMaking'],
      chapters: [
        {
          id: '2_c1',
          title: '1-р бүлэг: Тархины хоёр дүр',
          estimatedMinutes: 14,
          content:
              'Хүний тархи шийдвэр гаргахдаа Систем 1 (хурдан, автомат) болон Систем 2 (удаан, анхаарал шаардсан) гэсэн хоёр горимыг ашигладаг.',
        },
      ],
      reviews: [],
    },
    {
      id: '3',
      externalSource: 'central_seed',
      externalId: 'seed_sapiens',
      isbn13: '9780062316097',
      title: 'Sapiens: A Brief History of Humankind',
      normalizedTitle: 'sapiens a brief history of humankind',
      author: 'Yuval Noah Harari',
      normalizedAuthor: 'yuval noah harari',
      description:
          'Хүн төрөлхтний үүсэл хөгжил, танин мэдэхүйн хувьсгалаас хиймэл оюун ухааны эрин хүртэлх түүх.',
      rating: 4.8,
      reviewsCount: 2890,
      category: 'book.categories.history',
      pages: 443,
      readTimeMinutes: 380,
      image: 'assets/public/books/sapiens.png',
      colorHex: 0xFF7C2D12,
      hasAudio: true,
      audioDurationMinutes: 380,
      keyTakeaways: [
        'Хамтын төсөөлөл бол Хомо Сапиенсийг дэлхийг захирахад хүргэсэн гол хүч юм.',
      ],
      tags: ['History', 'Anthropology'],
      chapters: [
        {
          id: '3_c1',
          title: '1-р бүлэг: Танин мэдэхүйн хувьсгал',
          estimatedMinutes: 16,
          content:
              'Одоогоос 70,000 жилийн өмнө Хомо Сапиенсийн тархины бүтцэд гарсан өөрчлөлт нь хэл яриа болон хамтын итгэл үнэмшлийг бий болгожээ.',
        },
      ],
      reviews: [],
    },
  ];
}

module.exports = {
  registerMongooseCentralBookModel,
  getInitialCentralBooks,
};
