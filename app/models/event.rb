# == Schema Information
#
# Table name: events
#
#  id           :bigint           not null, primary key
#  external_id  :string           not null, unique
#  name         :string
#  payload      :jsonb
#  status       :string           default("pending")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# == Class Documentation
#
# The `Event` model is a **generic event processing system** designed to handle
# multiple webhook providers such as Stripe, PayPal, and others.
#
# **Key Design Choices:**
# - Uses `external_id` to ensure each event is unique and prevent duplicate processing.
# - Supports a flexible `name` field to store the type of event.
# - Stores the full event `payload` as `jsonb` for extensibility.
# - Implements an enum-based `status` field to track processing states.
#
# **Processing Flow:**
# 1. Events are recorded when received via webhooks.
# 2. An `EventProcessorJob` is triggered to handle the event asynchronously.
# 3. Status transitions:
#    - `pending` → Default state when created.
#    - `processing` → When being handled by a job.
#    - `finished` → Successfully processed.
#    - `failed` → If an unrecoverable error occurs.
#
# **Future Extensibility:**
# - Can be extended to support more webhook providers beyond Stripe.
# - Batch processing can be implemented to optimize event handling.
# - Additional metadata can be stored dynamically in `payload`.
#
class Event < ApplicationRecord
  PENDING = "pending"
  PROCESSING = "processing"
  FINISHED = "finished"
  FAILED = "failed"

  enum :status, {
    pending: PENDING,
    processing: PROCESSING,
    finished: FINISHED,
    failed: FAILED
  }

  validates :external_id, presence: true, uniqueness: true
  validates :name, :status, presence: true
end
