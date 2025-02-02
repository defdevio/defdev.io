FROM golang:alpine AS build
WORKDIR /build
COPY . .
RUN go build -o lambda-emailer

FROM alpine AS final
WORKDIR /app
COPY --from=build /build/lambda-emailer lambda-emailer
COPY ./mjml/email.mjml mjml/email.mjml
ENTRYPOINT [ "/app/lambda-emailer" ]