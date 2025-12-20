import { Injectable } from '@nestjs/common';
import { EmailParams, MailerSend, Recipient, Sender } from 'mailersend';
import { envVars, envVarValue } from '../config/constants/env-constants';
import { defaultConstants } from '../config/constants/default-constants';
// import { Resend } from 'resend';

@Injectable()
export class MailerSendService {
  private mailer: MailerSend;
  constructor() {
    this.mailer = new MailerSend({
      apiKey: envVarValue[envVars.MAILER_SEND_TOKEN],
    });
  }

  async sendVereficationEmailMailerSend(to: string, token: string) {
    // TODO: chage mail and app

    const sendForm = new Sender(
      envVarValue[envVars.MAILER_SEND_DOMEN],
      'Burger House',
    );

    const recipients = [new Recipient(to, 'User')];
    console.log(defaultConstants.domains.API);

    const emailParams = new EmailParams()
      .setFrom(sendForm)
      .setTo(recipients)
      .setSubject('Підтвердження реєстрації').setHtml(`
        <h1>Привіт!</h1>
        <p>Вітаю в команді!!!</p>
        <a href="${defaultConstants.domains.API}/admin/auth/verify/email/${token}">
        <strong>Натисни тут для завершення реєстрації.</strong></a>`);
    // <a href="${defaultConstants.domains.API}/admin/auth/verify/email/${token}">

    try {
      return await this.mailer.email.send(emailParams);
    } catch (error) {
      console.log(error);

      throw error;
    }
  }

  // async sendVerificationEmailResend(to: string, token: string) {
  //   const resend = new Resend('apiKEY');
  //   console.log(defaultConstants.domains.API);

  //   return await resend.emails.send({
  //     from: 'onboarding@resend.dev',
  //     to,
  //     subject: 'Підтвердження реєстрації',
  //     html: `
  //       <h1>Привіт!</h1>
  //       <p>Вітаю в команді!!!</p>
  //       <a href="${defaultConstants.domains.API}/admin/auth/verify/email/${token}">
  //       <strong>Натисни тут для завершення реєстрації.</strong></a>`,
  //   });
  // }
}
