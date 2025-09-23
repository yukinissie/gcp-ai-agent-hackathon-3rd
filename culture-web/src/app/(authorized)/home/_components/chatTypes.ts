export interface ChatMessage {
    id: string;
    content: string;
    sender: 'user' | 'ai';
    timestamp: string;
    isTyping?: boolean;
}

export interface ChatBotProps {
    onSendMessage?: (message: string) => Promise<string>;
    initialMessages?: ChatMessage[];
    className?: string;
    isOpen?: boolean;
    onClose?: () => void;
}

export interface ChatMessageProps {
    message: ChatMessage;
}

export interface ChatInputProps {
    onSendMessage: (message: string) => void;
    disabled?: boolean;
    placeholder?: string;
}
