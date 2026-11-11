'use strict';

function registerMongooseReadingEventModel(mongoose) {
  if (mongoose.models && mongoose.models.ReadingEvent) {
    return mongoose.models.ReadingEvent;
  }

  const schema = new mongoose.Schema(
    {
      userId: { type: String, required: true, index: true },
      eventId: { type: String, required: true },
      payloadHash: { type: String, required: true },
      bookId: { type: String, required: true },
      minutes: { type: Number, required: true, min: 0, max: 180 },
      timezoneOffsetMinutes: { type: Number, min: -840, max: 840, default: 0 },
      readingDate: { type: String, required: true },
      xp: { type: Number, required: true, min: 0 },
      status: { type: String, enum: ['pending', 'complete'], default: 'pending' },
      createdAt: { type: Date, default: Date.now },
      completedAt: { type: Date, default: null },
    },
    { versionKey: false }
  );
  schema.index({ userId: 1, eventId: 1 }, { unique: true });
  return mongoose.model('ReadingEvent', schema, 'reading_events');
}

module.exports = { registerMongooseReadingEventModel };
