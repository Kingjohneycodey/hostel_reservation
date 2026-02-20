import { v4 as uuidv4 } from 'uuid';
import { SendNotificationRequest, NotificationRecord, NotificationChannel } from '../models/Notification';
import { EVENT_CONFIGS } from '../models/Events';
import { getTemplate, renderTemplate } from '../templates/TemplateManager';
import { NotificationRepository } from '../repositories/NotificationRepository';
import { EmailService, SmsService } from './ChannelServices';
import { db } from '../config/firebase';

const getUserContact = async (userId: string) => {
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) return null;
    return userDoc.data() as { email: string, phoneNumber: string, fcmToken?: string };
};

export const NotificationService = {
    async sendNotification({ userId, event, payload, idempotencyKey }: SendNotificationRequest): Promise<void> {
        const config = EVENT_CONFIGS[event];
        if (!config) {
            throw new Error(`Invalid event type: ${event}`);
        }

        const user = await getUserContact(userId);
        if (!user) {
            console.error(`User not found: ${userId}`);
            return;
        }

        const templateSet = getTemplate(event);
        const channels: NotificationChannel[] = ['email', 'sms', 'in_app'];

        const records: NotificationRecord[] = channels.map(channel => {
            const tpl = templateSet[channel];
            const content = renderTemplate(tpl.body, payload);
            const title = tpl.subject ? renderTemplate(tpl.subject, payload) : '';

            const baseKey = idempotencyKey || `${userId}_${event}_${Date.now()}`;
            const uniqueKey = `${baseKey}_${channel}`;

            return {
                id: uuidv4(),
                userId,
                event,
                type: config.type,
                channel,
                title: title,
                message: content,
                priority: config.priority,
                status: 'pending',
                isRead: false,
                idempotencyKey: uniqueKey,
                metadata: payload,
                createdAt: new Date()
            };
        });

        await Promise.all(records.map(r => NotificationRepository.create(r)));

        records.forEach(async (record) => {
            try {
                if (record.channel === 'email') {
                    if (user.email) {
                        const sent = await EmailService.send(user.email, record.message, record.title);
                        await NotificationRepository.updateStatus(record.idempotencyKey, sent ? 'sent' : 'failed');
                    } else {
                        await NotificationRepository.updateStatus(record.idempotencyKey, 'failed', 'No Email');
                    }
                } else if (record.channel === 'sms') {
                    if (user.phoneNumber) {
                        const sent = await SmsService.send(user.phoneNumber, record.message);
                        await NotificationRepository.updateStatus(record.idempotencyKey, sent ? 'sent' : 'failed');
                    } else {
                        await NotificationRepository.updateStatus(record.idempotencyKey, 'failed', 'No Phone');
                    }
                } else if (record.channel === 'in_app') {
                    await NotificationRepository.updateStatus(record.idempotencyKey, 'sent');
                }
            } catch (err: any) {
                console.error(`Failed to send ${record.channel} for ${record.idempotencyKey}`, err);
                await NotificationRepository.updateStatus(record.idempotencyKey, 'failed', err.message);
            }
        });
    }
};